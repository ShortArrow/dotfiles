local M = {}

M.opts = {
  debug = false,     -- Enable debugging
  -- See Configuration section for rest
  prompts = {
    Explain = {
      prompt = '/COPILOT_EXPLAIN Write an explanation of the code under the cursor with paragraphs.',
    },
    Tests = {
      prompt = '/COPILOT_TESTS Write detailed unit test functions for the code under the cursor.',
    },
    Fix = {
      prompt = '/COPILOT_FIX There is a problem with this code. Rewrite it with the bug fixed.',
    },
    Optimize = {
      prompt = '/COPILOT_REFACTOR Optimize the selected code to improve performance and readability.',
    },
    Docs = {
      prompt =
      '/COPILOT_REFACTOR Write documentation for the selected code. Answer with a code block including the original code with documentation added as comments. Use the documentation style most appropriate for the programming language (e.g., JSDoc for JavaScript, docstrings for Python, etc.)',
    },
    FixDiagnostic = {
      prompt = 'Please fix the following diagnostic issue in the file:',
    }
  }
}

return M
