This is a retro-inspired, two-player, turn-based trivia strategy game designed to emulate the classic aesthetic and feel of the MSX Sakhr computers from the 1980s.

Core Objective:
Two teams (The Yellow Team and The Green Team) compete on a 5x5 hexagonal grid. The primary goal is to capture hexagons by answering trivia questions correctly to form a continuous, unbroken path connecting opposite sides of the board (either top-to-bottom or left-to-right).

Gameplay Mechanics:

    Grid Selection: Players take turns clicking on available hexagons. An animated "bee" mascot flies from the active team's base to the selected hex, triggering a custom 8-bit buzzing sound effect.

    Categories: Each hex is randomly assigned a category: History (تاريخ), Geography (جغرافيا), Science (علوم), Religion (دين), or a Mystery "؟" category (which randomly pulls from the other four).

    Dynamic Difficulty & Scaling: The game features an intelligent progression system. As a team captures more hexes, the game automatically increases the difficulty tier of the questions (Easy -> Medium -> Hard) and drastically reduces the time allowed to answer (15 seconds -> 11 seconds -> 8 seconds).

    Anti-Repetition Engine: The underlying logic tracks used questions in arrays, ensuring players never see the same question twice in a single session until a category's entire database is exhausted.

Technical & UI Features:

    Authentic Retro Audio: Instead of using audio files, the game utilizes a sophisticated JavaScript Web Audio API synthesizer. It generates real-time, polyphonic ADSR-enveloped chiptune waveforms for sound effects (timers, buzzing, wrong answers, and victory fanfares).

    Localization Toggle: A dynamic setting on the start screen allows players to instantly switch the entire game's numbering system between Western Arabic numerals (123) and Eastern Arabic/Indian numerals (١٢٣) using Regular Expressions (Regex).

    Responsive SVG Board: The hexagonal grid is drawn dynamically using scalable vector graphics (SVG) and mathematics, ensuring perfect alignment and interaction handling.