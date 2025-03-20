#!/bin/bash

declare -A pos_words
declare -A neg_words

while IFS= read -r word; do
	pos_words["$word"]=1
done < sentiment_txts/positive_words_en.txt

while IFS= read -r word; do
	neg_words["$word"]=1
done < sentiment_txts/negative_words_en.txt

DB_FILE="clean_prototype.ddb"
QUERY_REDDIT="SELECT id, body FROM small_reddit"
QUERY_TWITTER="SELECT status_id, text, lang FROM small_twitter"

# duckdb "$DB_FILE" -readonly -noheader -csv -separator '|' -c "$QUERY_REDDIT" | awk -F'|' '{ gsub(/[^a-zA-Z0-9 ]/, "", $2); print "ID:", $1, "Body:", $2 }'
# duckdb "$DB_FILE" -readonly -noheader -csv -separator '|' -c "$QUERY_TWITTER" | awk -F'|' '{ gsub(/[^a-zA-Z0-9 ]/, "", $2); print "ID:", $1, "Text:", $2 }'

# REDDIT
while IFS='|' read -r id body_text; do
    # echo "ID: $id"
    clean_body=$(echo "$body_text" | sed 's/[^a-zA-Z0-9 ]//g' | tr '[:upper:]' '[:lower:]')
    # echo "Body: $clean_body"

    sentiment_score=0
    for word in $clean_body; do
        if [[ -n "${pos_words[$word]}" ]]; then
		((sentiment_score++))
	elif [[ -n "${neg_words[$word]}" ]]; then
		((sentiment_score--))
	fi
    
    done
    # echo "Sentiment Score: $sentiment_score" 
duckdb "$DB_FILE" -c "UPDATE small_reddit SET sentiment_score = $sentiment_score WHERE id = '$id';"
    
done < <(duckdb "$DB_FILE" -readonly -noheader -csv -separator '|' -c "$QUERY_REDDIT")

# TWITTER
while IFS='|' read -r id body_text lang; do
    # echo "ID: $id"
    echo "Language: $lang"
    clean_text=$(echo "$body_text" | sed 's/[^a-zA-Z0-9 ]//g' | tr '[:upper:]' '[:lower:]')
    echo "Text: $clean_text"

    sentiment_score=0
    for word in $clean_text; do
        if [[ -n "${pos_words[$word]}" ]]; then
		((sentiment_score++))
	elif [[ -n "${neg_words[$word]}" ]]; then
		((sentiment_score--))
	fi
    
    done
    echo "Sentiment Score: $sentiment_score" 
duckdb "$DB_FILE" -c "UPDATE small_twitter SET sentiment_score = $sentiment_score WHERE status_id = '$id';"
    
done < <(duckdb "$DB_FILE" -readonly -noheader -csv -separator '|' -c "$QUERY_TWITTER")
