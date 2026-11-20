#!/usr/bin/env perl
# PreToolUse guard: the signing passphrase is cached by the user typing
# `! git unlock`, never by the agent running gpg --clearsign itself or
# handing that line to the user.
#
# Reads the hook's tool_input JSON on stdin. Prints a deny decision when a
# segment of the command line runs gpg with --clearsign (or --clear-sign);
# prints nothing otherwise. Silence is the allow verdict.
#
# gpg is gpg, gpg2 or gpg.exe by name or path, the gpg.program that
# `git config` prints, or a variable named gpg. The line is split into
# segments at ; & | ( ) { } and newlines that stand outside quotes, and each
# segment is judged by its leading command, so a commit message, a grep
# pattern or an echo that mentions --clearsign passes. git unlock passes:
# its script uses --clearsign, but the line the agent runs does not.
use strict;
use warnings;
use utf8;
use JSON::PP;

my $reason = '署名のパスフレーズは ! git unlock でユーザーに入れてもらう。エージェントは打たない。'
  . ' (The signing passphrase is entered by the user with `! git unlock`; the agent does not run gpg --clearsign itself.)';

my $input = do { local $/; <STDIN> };
my $command = eval { decode_json($input)->{tool_input}{command} } // '';
exit 0 if $command eq '';

for my $segment (segments($command)) {
  my ($name, $rest) = leader($segment);
  next unless defined $name && is_gpg($name);
  next unless $rest =~ /\s--clear-?sign(?=\s|$)/i;
  print encode_json({
    hookSpecificOutput => {
      hookEventName => 'PreToolUse',
      permissionDecision => 'deny',
      permissionDecisionReason => $reason,
    },
  }), "\n";
  last;
}
exit 0;

sub is_gpg {
  my ($name) = @_;
  return $name =~ /^gpg2?$/
    || $name =~ /^\$\{?gpg\}?$/
    || $name =~ /^\$\(git\s+config\b.*\bgpg\.program\)$/;
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

# The command a segment runs, lowercased, without quotes, path or .exe, and
# the segment text from that command on. `cmd /c` and wrappers are looked
# through. A quoted command substitution is kept whole.
sub leader {
  my ($segment) = @_;
  my $rest = $segment;
  $rest =~ s/^\s*[&.!]\s+//;
  my ($token) = $rest =~ /^\s*("[^"]*"|'[^']*'|\S+)/;
  return unless defined $token;
  (my $name = lc $token) =~ tr/'"//d;
  $name =~ s{.*[\\/]}{} unless $name =~ /^\$\(/;
  $name =~ s/\.exe$//;
  my $after = substr($rest, index($rest, $token) + length $token);
  return leader($after) if $name =~ /^(?:sudo|exec|command|call)$/;
  if ($name eq 'cmd' && $after =~ s{^\s*/[ck]\s+}{}i) {
    return leader($after);
  }
  return ($name, $rest);
}
