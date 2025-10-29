#!/usr/bin/env bash
# Example hook: Redact sensitive data from messages
# Redacts common patterns like API keys, passwords, emails

set -e

input=$(cat)

# Modify the messages to redact sensitive data
output=$(echo "$input" | jq '
  .messages |= map(
    .content |= (
      if type == "string" then
        . | gsub("sk-[a-zA-Z0-9]{48}"; "[REDACTED_API_KEY]")
          | gsub("password[\":\\s]+[^\\s\"]+"; "password: [REDACTED]"; "i")
          | gsub("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"; "[REDACTED_EMAIL]")
      else
        .
      end
    )
  )
')

echo "$output"
