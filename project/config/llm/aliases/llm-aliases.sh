#!/usr/bin/env bash
# source ~/.config/llm/aliases/llm-aliases.sh

# ===== CLAUDE CODE =====
alias cld='claude'
alias cld-code='claude --code'
alias cld-chat='claude -p'

# ===== OPENAI =====
alias cod='openai'
alias cod-fix='openai --suggest'

# ===== GROQ =====
alias grq='groq'
alias grq-fast='groq --model llama-3.3-70b'

# ===== UNIVERSAL COMMAND =====
ask() {
    local provider="${DEFAULT_LLM_PROVIDER:-claude}"
    local query="$@"

    case "$provider" in
        claude)
            echo "$query" | claude -
            ;;
        groq)
            grq "$query"
            ;;
        openai)
            cod "$query"
            ;;
        *)
            echo "Provider desconhecido: $provider"
            ;;
    esac
}
