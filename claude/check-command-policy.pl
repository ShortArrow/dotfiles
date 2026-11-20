#!/usr/bin/env perl
# PreToolUse guard for machines that enable it: commands that persist, hide or reach out
# are refused (ERROR), confirmed (WARN) or logged (INFO).
#
# Reads the hook's tool_input JSON on stdin. Prints a deny decision for an
# ERROR, an ask decision for a WARN, and nothing otherwise; silence is the
# allow verdict. Every hit, at every level, appends one line to the log:
#   time <TAB> level <TAB> labels <TAB> command (newlines as \n)
# The log is $CLAUDE_COMMAND_POLICY_LOG, or ~/.claude/logs/command-policy.log.
#
# A rule fires on the command a segment runs, not on a word anywhere in the
# line. The line is split into segments at ; & | ( ) { } and newlines that
# stand outside quotes, and each segment is judged by its leading command,
# so a quoted string, a commit message, a grep pattern or an echo that only
# mentions a word matches nothing. A here-document body counts as commands
# only when it feeds a shell; fed to anything else it is text.
#
# A segment led by ssh runs on another machine. It is never refused or
# confirmed here, only logged; what it may run is the remote host's policy
# and the ssh task check in the engineering-skills plugin's. Only the command line is read: the body of
# a script sent with scp, or of any .ps1 started with -File, is not seen.
use strict;
use warnings;
use JSON::PP;
use POSIX qw(strftime);
use File::Basename qw(dirname);
use File::Path qw(make_path);

my %message = (
  'scheduled task' => 'Registering, changing or deleting a scheduled task is forbidden on this machine (schtasks /create, /change, /delete, Register-ScheduledTask). Ask the user to do it. On an ssh host, send the registration as a script with scp and start only that script over ssh.',
  'encoded command' => 'powershell/pwsh -EncodedCommand is forbidden on this machine: an encoded script cannot be read before it runs. Pass the script as plain text with -Command, or save it as a .ps1 and run it with -File.',
  'service' => 'Creating a Windows service is forbidden on this machine (sc create, New-Service). Ask the user to do it.',
  'wmi process' => 'Starting a process through WMI is forbidden on this machine (wmic process call create, Invoke-CimMethod or Invoke-WmiMethod on Win32_Process Create). Run the command directly.',
  'execution policy bypass' => 'Confirm: -ExecutionPolicy Bypass turns the script policy off. A script sent with scp carries no Zone.Identifier and runs under RemoteSigned: powershell -NoProfile -ExecutionPolicy RemoteSigned -File <script>.',
  'remoting' => 'Confirm: PowerShell remoting runs commands on another computer (Invoke-Command, Enter-PSSession, New-PSSession).',
  'psexec' => 'Confirm: PsExec runs a command on another computer or as SYSTEM.',
  'runas' => 'Confirm: Start-Process -Verb RunAs starts an elevated process.',
  'run key' => 'Confirm: writing to CurrentVersion\Run or RunOnce makes a program start at every logon.',
  'startup folder' => 'Confirm: writing to the Startup folder (Start Menu\Programs\Startup) makes a program start at every logon.',
);

my %shells = map { $_ => 1 } qw(pwsh powershell bash sh zsh cmd);
my %wrappers = map { $_ => 1 } qw(sudo nice time exec command call noglob);
my %remoting = map { $_ => 1 } qw(invoke-command icm enter-pssession etsn new-pssession nsn);
my %registry_writers = map { $_ => 1 } qw(
  set-itemproperty sp new-itemproperty remove-itemproperty rp rename-itemproperty rnp
  copy-itemproperty cpp move-itemproperty mp new-item ni remove-item ri);
my %file_writers = map { $_ => 1 } qw(
  copy-item cp cpi copy move-item mv mi move new-item ni set-content add-content ac
  out-file tee-object tee xcopy robocopy mklink);

my $input = do { local $/; <STDIN> };
my $command = eval { decode_json($input)->{tool_input}{command} } // '';
exit 0 if $command eq '';

my @hits;
for my $segment (segments(drop_text_heredocs($command))) {
  push @hits, judge($segment);
}
exit 0 unless @hits;

write_log(\@hits, $command);

for my $level (qw(ERROR WARN)) {
  my ($hit) = grep { $_->[0] eq $level } @hits;
  next unless $hit;
  my $decision = $level eq 'ERROR' ? 'deny' : 'ask';
  print encode_json({
    hookSpecificOutput => {
      hookEventName => 'PreToolUse',
      permissionDecision => $decision,
      permissionDecisionReason => $message{$hit->[1]},
    },
  }), "\n";
  last;
}
exit 0;

# Here-document bodies stay only when they feed a shell (run as commands) or
# ssh (folded into the ssh segment as one quoteless line); otherwise dropped.
sub drop_text_heredocs {
  my ($text) = @_;
  my @lines = split /\n/, $text, -1;
  my @out;
  while (@lines) {
    my $line = shift @lines;
    if ($line =~ /<<-?\s*(['"]?)(\w+)\1/) {
      my $end = $2;
      my ($before) = split /<</, $line, 2;
      my @heads = segments($before);
      my ($leader) = leader($heads[-1] // '');
      my @body;
      while (@lines) {
        my $next = shift @lines;
        last if $next =~ /^\s*\Q$end\E\s*\)?\s*"?\s*$/;
        push @body, $next;
      }
      $leader //= '';
      if ($shells{$leader}) {
        push @out, $line, @body;
      } elsif ($leader eq 'ssh') {
        (my $folded = join ' ', @body) =~ tr/'"//d;
        push @out, "$line $folded";
      } else {
        push @out, $line;
      }
      next;
    }
    push @out, $line;
  }
  return join "\n", @out;
}

sub segments {
  my ($text) = @_;
  my @out;
  my $current = '';
  my $quote = '';
  for my $char (split //, $text) {
    if ($quote) {
      $quote = '' if $char eq $quote;
      $current .= $char;
    } elsif ($char eq "'" || $char eq '"') {
      $quote = $char;
      $current .= $char;
    } elsif ($char =~ /[;&|(){}\n]/) {
      push @out, $current;
      $current = '';
    } else {
      $current .= $char;
    }
  }
  push @out, $current;
  return grep { /\S/ } map { s/^\s+|\s+$//gr } @out;
}

# The command a segment runs, lowercased, without path, quotes or .exe, and
# the segment text from that command on. Assignments, call operators and
# wrappers (sudo, cmd /c) are looked through.
sub leader {
  my ($segment) = @_;
  my $rest = $segment;
  $rest =~ s/^\s*\$[\w:{}]+\s*=\s*//;
  $rest =~ s/^\s*(?:\w+=\S*\s+)+//;
  $rest =~ s/^\s*[&.!]\s+//;
  my ($token) = $rest =~ /^\s*("[^"]*"|'[^']*'|\S+)/;
  return unless defined $token;
  (my $name = lc $token) =~ tr/'"//d;
  $name =~ s{.*[\\/]}{};
  $name =~ s/\.exe$//;
  my $after = substr($rest, index($rest, $token) + length $token);
  if ($wrappers{$name}) {
    $after =~ s/^\s*-n\s+-?\d+// if $name eq 'nice';
    return leader($after);
  }
  if ($name eq 'cmd' && $after =~ s{^\s*/[ck]\s+}{}i) {
    return leader($after);
  }
  return ($name, $rest);
}

sub judge {
  my ($segment) = @_;
  my ($name, $rest) = leader($segment);
  return unless defined $name;
  my $s = lc $rest;
  my @hits;
  my $hit = sub { push @hits, [@_] };

  if ($name eq 'ssh') {
    $hit->('INFO', 'ssh.*powershell') if $s =~ /\b(?:powershell|pwsh)\b/;
    $hit->('INFO', 'ssh.*schtasks') if $s =~ /\bschtasks\b/;
    $hit->('INFO', 'ssh.*wmic') if $s =~ /\bwmic\b/;
    $hit->('INFO', 'ssh.*sc create') if $s =~ /\bsc(?:\.exe)?\s+create\b/;
    return @hits;
  }

  if ($name =~ /^(?:start-process|saps|start)$/) {
    $hit->('WARN', 'runas') if $s =~ /-verb\s+['"]?runas\b/;
    my ($target) = $rest =~ /-filepath\s+("[^"]*"|'[^']*'|\S+)/i;
    ($target) = $rest =~ /^\S+\s+("[^"]*"|'[^']*'|[^\s-]\S*)/ unless defined $target;
    if (defined $target) {
      (my $inner = $rest) =~ s/^\S+\s+(?:-filepath\s+)?//i;
      push @hits, judge($inner);
    }
    return @hits;
  }

  $hit->('ERROR', 'scheduled task')
    if $name eq 'schtasks' && $s =~ /[\s'"][\/-](?:create|change|delete)\b/;
  $hit->('ERROR', 'scheduled task') if $name eq 'register-scheduledtask';
  $hit->('ERROR', 'encoded command')
    if $name =~ /^(?:powershell|pwsh)$/ && $s =~ /\s-(?:e|ec|enc\w*)(?=\s|$)/;
  $hit->('ERROR', 'service')
    if $name eq 'sc' && $s =~ /^\S+\s+(?:\\\\\S+\s+)?create\b/;
  $hit->('ERROR', 'service') if $name eq 'new-service';
  $hit->('ERROR', 'wmi process')
    if $name eq 'wmic' && $s =~ /\bprocess\b.*\bcreate\b/;
  $hit->('ERROR', 'wmi process')
    if $name =~ /^(?:invoke-cimmethod|invoke-wmimethod)$/
    && $s =~ /\bwin32_process\b/ && $s =~ /\bcreate\b/;

  $hit->('WARN', 'execution policy bypass')
    if $name =~ /^(?:powershell|pwsh)$/
    && $s =~ /\s-(?:executionpolicy|ep|ex|exec\w*)\s+['"]?bypass\b/;
  $hit->('WARN', 'execution policy bypass')
    if $name eq 'set-executionpolicy' && $s =~ /\bbypass\b/;
  $hit->('WARN', 'remoting') if $remoting{$name};
  $hit->('WARN', 'psexec') if $name =~ /^psexec(?:64)?$/;

  my $run_key = qr/currentversion[\\\/]+run(?:once)?\b/;
  $hit->('WARN', 'run key')
    if $s =~ $run_key
    && ($registry_writers{$name}
        || ($name eq 'reg' && $s =~ /^\S+\s+(?:add|delete|import|copy|restore|load)\b/));

  my $startup = qr/start menu[\\\/]+programs[\\\/]+startup|shell:(?:common\s)?startup/;
  $hit->('WARN', 'startup folder')
    if ($file_writers{$name} && $s =~ $startup)
    || $s =~ /\>\s*['"]?[^'"]*?$startup/;

  return @hits;
}

sub write_log {
  my ($hits, $command) = @_;
  my $path = $ENV{CLAUDE_COMMAND_POLICY_LOG}
    // ($ENV{HOME} // $ENV{USERPROFILE} // '.') . '/.claude/logs/command-policy.log';
  my %rank = (ERROR => 3, WARN => 2, INFO => 1);
  my ($top) = sort { $rank{$b} <=> $rank{$a} } map { $_->[0] } @$hits;
  my %seen;
  my $labels = join ',', grep { !$seen{$_}++ } map { $_->[1] } @$hits;
  (my $flat = $command) =~ s/\r?\n/\\n/g;
  $flat =~ tr/\t/ /;
  eval {
    make_path(dirname($path));
    open my $fh, '>>:encoding(UTF-8)', $path or die;
    print $fh join("\t", strftime('%Y-%m-%dT%H:%M:%S%z', localtime), $top, $labels, $flat), "\n";
    close $fh;
  };
}
