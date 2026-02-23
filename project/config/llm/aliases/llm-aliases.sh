#!/bin/bash
# ~/.config/llm/aliases/llm-aliases.sh

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

# ===== GEMINI (via curl) =====
gemini-ask() {
    local query="$@"
    curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent" \
        -H "Content-Type: application/json" \
        -H "x-goog-api-key: $GOOGLE_API_KEY" \
        -d "{\"contents\": [{\"parts\": [{\"text\": \"$query\"}]}]}" | jq -r '.contents[0].parts[0].text' 2>/dev/null || echo "Erro ao chamar Gemini"
}
alias gem='gemini-ask'

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
        gemini)
            gem "$query"
            ;;
        *)
            echo "Provider desconhecido: $provider"
            ;;
    esac
}

# ===== UTILITIES =====
llm-status() {
    echo "=== LLM Status ==="
    which claude && echo "Claude: ✅" || echo "Claude: ❌"
    which openai && echo "OpenAI: ✅" || echo "OpenAI: ❌"
    which groq && echo "Groq: ✅" || echo "Groq: ❌"
    [ -n "$GOOGLE_API_KEY" ] && echo "Gemini: ✅" || echo "Gemini: ❌"
}

llm-use() {
    local provider="$1"
    case "$provider" in
        claude|groq|openai|gemini)
            export DEFAULT_LLM_PROVIDER="$provider"
            echo "Switched to $provider"
            ;;
        *)
            echo "Use: llm-use [claude|groq|openai|gemini]"
            ;;
    esac
}

llm-config-show() {
    cat ~/.config/llm/config.json | jq '.'
}
