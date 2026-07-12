<img>

# BeatNode
BeatNode is an iOS app that uses low-latency edge computing and heuristic algorithms to predict the 3 next best songs to play while DJing based on the current song's tempo and key.

## README GUIDE
- Project Structure
- How to Use the App
- Data & Execution
- How the App Works


# PROJECT STRUCTURE
```text
BeatNode
├── ML/
│   ├──
```

# HOW TO USE
- Upon opening the app, the user is prompted to a search bar that looks for the song based on either name or artist/producer 
- Once a song is picked, three more songs are suggested based on the current song's BPM and key similarity
- Once another song is chosen, more song suggestions are made and the process repeats until there are no more songs left in the database [```dj_library.csv```]

# DATA & EXECUTION

**```dj_library.csv``` Format**
| title | artist | bpm | key |
| -------- | -------- | -------- | -------- |
| Sippin' Yak  | Cloonee  | 127  | 1A  |
| Losing It | Fisher  | 125  | 6A  |
| If U Need It  | Sammy Virji  | 132  | 2A  |




