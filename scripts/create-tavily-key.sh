#!/bin/bash

# Check if Bitwarden session is active
if [ -z "$BW_SESSION" ]; then
    echo "❌ Bitwarden session not set. Run: just setup-bitwarden"
    exit 1
fi

# Check if item already exists
existing_item=$(bw list items --search "Tavily API Key" 2>/dev/null | jq -r '.[0].id // empty')

if [ -n "$existing_item" ]; then
    echo "⚠️  Tavily API Key already exists in Bitwarden"
    echo -n "Do you want to update it? (y/N): "
    read -r response < /dev/tty
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
    
    echo -n "Enter your new Tavily API key: "
    read -s api_key < /dev/tty
    echo ""
    
    # Sync vault before updating
    echo "Syncing vault..."
    bw sync
    
    # Update existing item
    echo "Updating existing item..."
    if bw get item "$existing_item" | jq \
      --arg password "$api_key" \
      '.login.password = $password' \
      | bw encode | bw edit item "$existing_item"; then
        echo "✅ Tavily API key updated in Bitwarden!"
    else
        echo "❌ Failed to update API key in Bitwarden"
        exit 1
    fi
else
    echo "Creating Tavily API key in Bitwarden..."
    echo -n "Enter your Tavily API key: "
    read -s api_key < /dev/tty
    echo ""

    # Create new item
    echo "Creating item in Bitwarden..."
    if bw get template item | jq \
      --arg name "Tavily API Key" \
      --arg username "tavily" \
      --arg password "$api_key" \
      --arg notes "API key for Tavily web search services used in avante.nvim" \
      '.type = 1 | .name = $name | .login.username = $username | .login.password = $password | .notes = $notes' \
      | bw encode | bw create item; then
        echo "✅ Tavily API key stored in Bitwarden!"
    else
        echo "❌ Failed to store API key in Bitwarden"
        exit 1
    fi
fi