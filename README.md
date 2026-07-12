<img>

# BeatNode
BeatNode is an iOS app that uses low-latency edge computing and heuristic algorithms to predict the 3 next best songs to play while DJing based on the current song's key and beats per minute.

## README GUIDE
- Project Structure
- How to Use the App
- Data & Model
- Inside the App


# PROJECT STRUCTURE
```text
BeatNode
├── ML/
│   ├──
```

# HOW TO USE
- Upon opening the app, the user is prompted to a search bar that looks for the song based on either its title or artist/producer name
- Once a song is picked, three more songs are suggested below the search bar based on the current song's BPM and key similarity
- Once another song is chosen, more 3 song suggestions are made and the process repeats until there are no more songs left in the database [```dj_library.csv```]

# DATA & MODEL

## DATA

**```dj_library.csv``` Header**
| title | artist | bpm | key |
| -------- | -------- | -------- | -------- |
| Sippin' Yak  | Cloonee  | 127  | 1A  |
| Losing It | Fisher  | 125  | 6A  |
| If U Need It  | Sammy Virji  | 132  | 2A  |

- Here is a sneak peak at what the data for each song looks like in the dataset
- There are 4 features for each song: title, artist, beats per minute, and key
- The model, however, only considers BPM and Key in the prediction because they are many different 

<>

- Typically, songs' keys are written as Ab, F# minor, or C major, but I used the Camelot Wheel to easily find songs within a ____
- To find songs in similar keys on the Camelot Wheel, you observe adjacent number or letter segments 
- For example: if a song's key is in 10A (D-flat minor), other mixable songs would be 11A, 9A, or 10B


## MODEL 

- The model uses K-Nearest Neighbors to generate 3 song reccomendations 
- As house songs' tempos are all in a similar 127-133 range, I applied 70% weights on the key and only 30% weights on the BPM
- Slower or faster tempos characterize different subgenres of house, x
- 









