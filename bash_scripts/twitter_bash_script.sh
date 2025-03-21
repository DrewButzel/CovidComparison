#!/bin/bash

declare -A pos_words_en
declare -A neg_words_en
declare -A pos_words_es
declare -A neg_words_es
declare -A pos_words_fr
declare -A neg_words_fr
declare -A pos_words_tr
declare -A neg_words_tr
declare -A pos_words_it
declare -A neg_words_it

while IFS= read -r word; do
	pos_words_en["$word"]=1
done < sentiment_txts/positive_words_en.txt
while IFS= read -r word; do
	neg_words_en["$word"]=1
done < sentiment_txts/negative_words_en.txt
while IFS= read -r word; do
	pos_words_es["$word"]=1
done < sentiment_txts/positive_words_es.txt
while IFS= read -r word; do
	neg_words_es["$word"]=1
done < sentiment_txts/negative_words_es.txt
while IFS= read -r word; do
	pos_words_fr["$word"]=1
done < sentiment_txts/positive_words_fr.txt
while IFS= read -r word; do
	neg_words_fr["$word"]=1
done < sentiment_txts/negative_words_fr.txt
while IFS= read -r word; do
	pos_words_tr["$word"]=1
done < sentiment_txts/positive_words_tr.txt
while IFS= read -r word; do
	neg_words_tr["$word"]=1
done < sentiment_txts/negative_words_tr.txt
while IFS= read -r word; do
	pos_words_it["$word"]=1
done < sentiment_txts/positive_words_it.txt
while IFS= read -r word; do
	neg_words_it["$word"]=1
done < sentiment_txts/negative_words_it.txt

DB_FILE="fulldata.ddb"
file="twitter_full_cleaned/twitter_full.csv"

progress_interval=5000
line=0

while IFS=',' read -r id lang body_text; do
    ((line++))
    if ((line % progress_interval == 0)); then
        echo "$line"
    fi
    
    clean_text=$(echo "$body_text" | sed 's/[^a-zA-Z0-9[:space:]]//g' | tr '[:upper:]' '[:lower:]')

    sentiment_score=0

    if [[ "$lang" == "en" || "$lang" == "und" ]]; then
	for word in $clean_text; do
            if [[ -n "${pos_words_en[$word]}" ]]; then
		((sentiment_score++))
	    fi
	    if [[ -n "${neg_words_en[$word]}" ]]; then
		((sentiment_score--))
	    fi
    
        done
    elif [[ "$lang" == "es" ]]; then
	for word in $clean_text; do
            if [[ -n "${pos_words_es[$word]}" ]]; then
		((sentiment_score++))
	    fi
	    if [[ -n "${neg_words_es[$word]}" ]]; then
		((sentiment_score--))
	    fi
    
        done
    elif [[ "$lang" == "fr" ]]; then
	for word in $clean_text; do
            if [[ -n "${pos_words_fr[$word]}" ]]; then
		((sentiment_score++))
	    fi
	    if [[ -n "${neg_words_fr[$word]}" ]]; then
		((sentiment_score--))
	    fi
    
        done
    elif [[ "$lang" == "tr" ]]; then
	for word in $clean_text; do
            if [[ -n "${pos_words_tr[$word]}" ]]; then
		((sentiment_score++))
	    fi
	    if [[ -n "${neg_words_tr[$word]}" ]]; then
		((sentiment_score--))
	    fi
    
        done
    elif [[ "$lang" == "it" ]]; then
	for word in $clean_text; do
            if [[ -n "${pos_words_it[$word]}" ]]; then
		((sentiment_score++))
	    fi
	    if [[ -n "${neg_words_it[$word]}" ]]; then
		((sentiment_score--))
	    fi
    
        done
    fi
 
    duckdb "$DB_FILE" <<EOF
INSERT INTO full_twitter (status_id, lang, text, sentiment_score)
VALUES ('$id', '$lang', '$clean_text', $sentiment_score);
EOF
done < "$file"
