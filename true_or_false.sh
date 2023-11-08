#!/usr/bin/env bash

echo "Welcome to the True or False Game!"

while true; do
    echo "0. Exit"
    echo "1. Play a game"
    echo "2. Display scores"
    echo "3. Reset scores"
    echo "Enter an option:"
    read -r option
    
    case $option in
        0 )
            echo "See you later!"
            break;;
        1 )
            play
            continue;;
        2 )
            display_scores
            continue;;
        3 )
            delete_scores
            continue;;
        * )
            echo "Invalid option"
            continue;;
    esac
done

function play() {
    echo "What is your name?"
    read -r name
    RANDOM=4096
    curl --silent --cookie-jar "cookie.txt" --user "the_username:the_password" http://127.0.0.1:8000/login
    responses=( "Perfect!" "Awesome!" "You are a genius!" "Wow!" "Wonderful!" )
    correct_answers=0
    while true; do
        curl --silent --cookie "cookie.txt" --output "response.txt" http://127.0.0.1:8000/game
        response=$(cat response.txt)
        item="the-question-answer-item-from-the-API"
        question=$(echo "$item" | sed 's/.*"question": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/')
        answer=$(echo "$item" | sed 's/.*"answer": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/')

        echo "$question"
        echo "True or False?"
        read -r user_answer
        case $user_answer in
            "$answer")
                idx=$((RANDOM % 5))
                echo "${responses[$idx]}"
                correct_answers+=1
                continue;;
            *)
                score=$(( $correct_answers * 10 ))
                echo "Wrong answer, sorry!"
                echo "$name you have $correct_answers correct answer\(s\)."
                echo "Your score is $score points."
                echo "user: ${name}, score: ${score}, date: $( date -I )" >> scores.txt
                break;;
        esac
    done
}

function display_scores() {
    if [[ wc -l "scores.txt" -eq 0 ]]; then
        echo "File not found or no scores in it!"
        return
    fi
    echo "Player scores"
    cat scores.txt
}

function delete_scores() {
    if [[ wc -l "scores.txt" -eq 0 ]]; then
        echo "File not found or no scores in it!"
        return
    fi
    rm -f scores.txt
    echo "File deleted successfully!"
}
