#!/bin/bash

declare -A pos_words_en
declare -A neg_words_en

while IFS= read -r word; do
	pos_words_en["$word"]=1
done < sentiment_txts/positive_words_en.txt
while IFS= read -r word; do
	neg_words_en["$word"]=1
done < sentiment_txts/negative_words_en.txt

DB_FILE="fulldata.ddb"
file="reddit_full_cleaned/reddit_full.csv"

progress_interval=5000
line=0

while IFS=',' read -r id lang body_text; do
    ((line++))
    if ((line % progress_interval == 0)); then
        echo "$line"
    fi

    clean_text=$(echo "$body_text" | sed 's/[^a-zA-Z0-9[:space:]]//g' | tr '[:upper:]' '[:lower:]')

    sentiment_score=0

    for word in $clean_text; do
    	if [[ -n "${pos_words_en[$word]}" ]]; then
		((sentiment_score++))
	fi
	if [[ -n "${neg_words_en[$word]}" ]]; then
		((sentiment_score--))
	fi
    done
    
    duckdb "$DB_FILE" <<EOF
INSERT INTO full_reddit (id, body, sentiment_score)
VALUES ('$id', '$clean_text', $sentiment_score);
EOF
done < "$file"
