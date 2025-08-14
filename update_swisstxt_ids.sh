#!/bin/bash

# Script to update SwissTxt API IDs in swisstxt.yml
# This script fetches current IDs from the SwissTxt API and updates the configuration file

API_BASE="https://sport.api.swisstxt.ch/v1"
YAML_FILE="backend/src/main/resources/sources/swisstxt.yml"

echo "🔄 Updating SwissTxt API IDs..."

# Function to extract competition ID from API response
get_competition_id() {
    local endpoint=$1
    local response=$(curl -s "${API_BASE}/football/${endpoint}?lang=de")
    # Extract the correct ID from the response - most competitions use .id field
    echo "$response" | jq -r '.id'
}

# Function to extract Champions League phase IDs
get_champions_league_ids() {
    local response=$(curl -s "${API_BASE}/football/champions-league?lang=de")
    
    # Extract all round IDs and their sub-rounds (Hinspiele/Rückspiele)
    echo "$response" | jq -r '
        .rounds[] | 
        select(.subRounds != null) | 
        "\(.id)|\(.name)|\(.subRounds[0].id)|\(.subRounds[1].id // "")"
    '
}

# Get current IDs
echo "📡 Fetching current IDs from API..."

BUNDESLIGA_ID=$(get_competition_id "bundesliga")
PREMIER_LEAGUE_ID=$(get_competition_id "premier-league")
SERIE_A_ID=$(get_competition_id "serie-a")
LIGUE_1_ID=$(get_competition_id "ligue-1")
LA_LIGA_ID=$(get_competition_id "primera-division")
EUROPA_LEAGUE_ID=$(get_competition_id "europa-league")

# Ice Hockey IDs
NATIONAL_LEAGUE_ID=$(get_competition_id "hockey/nla")
SWISS_LEAGUE_ID=$(get_competition_id "hockey/nlb")
NHL_ID=$(get_competition_id "hockey/nhl")

echo "✅ Found league IDs:"
echo "   Bundesliga: $BUNDESLIGA_ID"
echo "   Premier League: $PREMIER_LEAGUE_ID"
echo "   Serie A: $SERIE_A_ID"
echo "   Ligue 1: $LIGUE_1_ID"
echo "   La Liga: $LA_LIGA_ID"
echo "   Europa League: $EUROPA_LEAGUE_ID"
echo ""
echo "✅ Found ice hockey league IDs:"
echo "   National League: $NATIONAL_LEAGUE_ID"
echo "   Swiss League: $SWISS_LEAGUE_ID"
echo "   NHL: $NHL_ID"

# Get Champions League IDs
echo "📡 Fetching Champions League phase IDs..."
CL_DATA=$(get_champions_league_ids)

echo "✅ Found Champions League phases:"
echo "$CL_DATA" | while IFS='|' read -r round_id round_name sub1_id sub2_id; do
    echo "   $round_name: $round_id (Hinspiele: $sub1_id, Rückspiele: $sub2_id)"
done

# Backup original file
echo "💾 Creating backup of original file..."
cp "$YAML_FILE" "${YAML_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

# Update the YAML file
echo "📝 Updating $YAML_FILE..."

# Function to update a specific league ID
update_league_id() {
    local league_name=$1
    local new_id=$2
    
    # Find the line with the league name and update the next line containing 'id:'
    awk -v league="$league_name" -v id="$new_id" '
        /name: / && $2 == league { 
            print; 
            getline; 
            if (/id:/) {
                sub(/id: "[^"]*"/, "id: \"" id "\"");
            }
            print;
            next;
        }
        { print }
    ' "$YAML_FILE" > "${YAML_FILE}.tmp" && mv "${YAML_FILE}.tmp" "$YAML_FILE"
}

# Update basic league IDs
echo "   Updating Bundesliga ID..."
update_league_id "BUNDESLIGA" "$BUNDESLIGA_ID"

echo "   Updating Premier League ID..."
update_league_id "PREMIER_LEAGUE" "$PREMIER_LEAGUE_ID"

echo "   Updating Serie A ID..."
update_league_id "SERIE_A" "$SERIE_A_ID"

echo "   Updating Ligue 1 ID..."
update_league_id "LIGUE_1" "$LIGUE_1_ID"

echo "   Updating La Liga ID..."
update_league_id "LA_LIGA" "$LA_LIGA_ID"

echo "   Updating Europa League ID..."
update_league_id "EUROPA_LEAGUE" "$EUROPA_LEAGUE_ID"

# Update Ice Hockey IDs
echo "   Updating National League Qualification ID..."
update_league_id "NATIONAL_LEAGUE_QUALIFICATION" "$NATIONAL_LEAGUE_ID"

echo "   Updating Swiss League Qualification ID..."
update_league_id "SWISS_LEAGUE_QUALIFICATION" "$SWISS_LEAGUE_ID"

echo "   Updating NHL Qualification ID..."
update_league_id "NHL_QUALIFICATION" "$NHL_ID"

# Update Champions League IDs
echo "   Updating Champions League phase IDs..."

# Update CL phases with a more robust approach
update_cl_phases() {
    echo "$CL_DATA" | while IFS='|' read -r round_id round_name sub1_id sub2_id; do
        case "$round_name" in
            *"1. Quali-Runde"*)
                echo "      - 1. Qualification Round: $sub1_id, $sub2_id"
                # Update first occurrence of CL_QUALIFICATION_1
                awk -v id="$sub1_id" '
                    /name: CL_QUALIFICATION_1/ && !found1 { 
                        print; getline; 
                        if (/id:/) sub(/id: "[^"]*"/, "id: \"" id "\""); 
                        print; found1=1; next 
                    } 
                    { print }
                ' "$YAML_FILE" > "${YAML_FILE}.tmp1" && mv "${YAML_FILE}.tmp1" "$YAML_FILE"
                
                # Update second occurrence of CL_QUALIFICATION_1
                awk -v id="$sub2_id" '
                    /name: CL_QUALIFICATION_1/ { 
                        if (count++ == 1) { 
                            print; getline; 
                            if (/id:/) sub(/id: "[^"]*"/, "id: \"" id "\""); 
                            print; next 
                        } 
                    } 
                    { print }
                ' "$YAML_FILE" > "${YAML_FILE}.tmp2" && mv "${YAML_FILE}.tmp2" "$YAML_FILE"
                ;;
            *"2. Quali-Runde"*)
                echo "      - 2. Qualification Round: $sub1_id, $sub2_id"
                # Similar logic for CL_QUALIFICATION_2
                awk -v id="$sub1_id" '
                    /name: CL_QUALIFICATION_2/ && !found1 { 
                        print; getline; 
                        if (/id:/) sub(/id: "[^"]*"/, "id: \"" id "\""); 
                        print; found1=1; next 
                    } 
                    { print }
                ' "$YAML_FILE" > "${YAML_FILE}.tmp1" && mv "${YAML_FILE}.tmp1" "$YAML_FILE"
                
                awk -v id="$sub2_id" '
                    /name: CL_QUALIFICATION_2/ { 
                        if (count++ == 1) { 
                            print; getline; 
                            if (/id:/) sub(/id: "[^"]*"/, "id: \"" id "\""); 
                            print; next 
                        } 
                    } 
                    { print }
                ' "$YAML_FILE" > "${YAML_FILE}.tmp2" && mv "${YAML_FILE}.tmp2" "$YAML_FILE"
                ;;
            *"3. Quali-Runde"*)
                echo "      - 3. Qualification Round: $sub1_id, $sub2_id"
                # Similar logic for CL_QUALIFICATION_3
                awk -v id="$sub1_id" '
                    /name: CL_QUALIFICATION_3/ && !found1 { 
                        print; getline; 
                        if (/id:/) sub(/id: "[^"]*"/, "id: \"" id "\""); 
                        print; found1=1; next 
                    } 
                    { print }
                ' "$YAML_FILE" > "${YAML_FILE}.tmp1" && mv "${YAML_FILE}.tmp1" "$YAML_FILE"
                
                awk -v id="$sub2_id" '
                    /name: CL_QUALIFICATION_3/ { 
                        if (count++ == 1) { 
                            print; getline; 
                            if (/id:/) sub(/id: "[^"]*"/, "id: \"" id "\""); 
                            print; next 
                        } 
                    } 
                    { print }
                ' "$YAML_FILE" > "${YAML_FILE}.tmp2" && mv "${YAML_FILE}.tmp2" "$YAML_FILE"
                ;;
            *"Playoff-Round"*)
                echo "      - Playoff Round: $sub1_id, $sub2_id"
                # Similar logic for CL_PLAYOFF_ROUND
                awk -v id="$sub1_id" '
                    /name: CL_PLAYOFF_ROUND/ && !found1 { 
                        print; getline; 
                        if (/id:/) sub(/id: "[^"]*"/, "id: \"" id "\""); 
                        print; found1=1; next 
                    } 
                    { print }
                ' "$YAML_FILE" > "${YAML_FILE}.tmp1" && mv "${YAML_FILE}.tmp1" "$YAML_FILE"
                
                awk -v id="$sub2_id" '
                    /name: CL_PLAYOFF_ROUND/ { 
                        if (count++ == 1) { 
                            print; getline; 
                            if (/id:/) sub(/id: "[^"]*"/, "id: \"" id "\""); 
                            print; next 
                        } 
                    } 
                    { print }
                ' "$YAML_FILE" > "${YAML_FILE}.tmp2" && mv "${YAML_FILE}.tmp2" "$YAML_FILE"
                ;;
        esac
    done
}

update_cl_phases

# Clean up temporary files
rm -f "${YAML_FILE}.tmp"

echo "✅ Update completed!"
echo ""
echo "🔍 Updated IDs:"
echo "   Bundesliga: $BUNDESLIGA_ID"
echo "   Premier League: $PREMIER_LEAGUE_ID"
echo "   Serie A: $SERIE_A_ID" 
echo "   Ligue 1: $LIGUE_1_ID"
echo "   La Liga: $LA_LIGA_ID"
echo "   Europa League: $EUROPA_LEAGUE_ID"
echo ""
echo "🏒 Updated Ice Hockey IDs:"
echo "   National League: $NATIONAL_LEAGUE_ID"
echo "   Swiss League: $SWISS_LEAGUE_ID"
echo "   NHL: $NHL_ID"
echo ""
echo "Champions League phases updated with current round IDs."
echo ""
echo "⚠️  Note: Please review the updated file before committing changes."
echo "📄 Backup was created with timestamp."