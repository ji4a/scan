#!/bin/bash

source tokens.sh

####### Function to decode HTML entities #######
decode_html_entities() {
    local decoded_text=$(echo "$1" | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; s/&#39;/\x27/g; s/&ldquo;/“/g; s/&rdquo;/”/g; s/&lsquo;/‘/g; s/&rsquo;/’/g; s/&ndash;/–/g; s/&mdash;/—/g;')
    echo "$decoded_text"
}

####### Function to get the last article title and URL from the provided website #######
get_last_article_info() {
    local website_url="https://www.bleepingcomputer.com"
    local article_info=$(curl -s "$website_url" | sed -n '/<ul id="bc-home-news-main-wrap">/,/<\/ul>/p' | grep -o '<h4><a[^>]*>[^<]*</a></h4>' | tail -n 1)
    local article_title=$(echo "$article_info" | sed 's/<[^>]*>//g')
    local article_url=$(echo "$article_info" | grep -o 'https://[^"]*')
    echo "$article_title -> $article_url"
}

####### Function to send message to Telegram bot #######
send_message_to_telegram_bot() {
    local bot_token="$TELEGRAM_BOT_TOKEN"
    local chat_id="$CHAT_ID"
    local title="$1"
    local url="$2"
    local message="$title $url"
    local url_encoded_message=$(printf "%s" "$message" | jq -s -R -r @uri)
    curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage" -d "chat_id=$chat_id" -d "text=$url_encoded_message"
}

####### Main function #######
main() {
    local last_article=""
    while true; do
        local article_info=$(get_last_article_info)
        if [ "$article_info" != "$last_article" ]; then
            IFS=',' read -r article_title article_url <<< "$article_info"
            if [ -n "$article_title" ]; then
                send_message_to_telegram_bot "$(decode_html_entities "$article_title")" "$article_url"
                echo "New article sent to Telegram bot: $article_title $article_url"
                last_article="$article_info"
            fi
        fi
        sleep 300  # SCAN EVERY 5 MINUTES
    done
}

# Call the main function
main
