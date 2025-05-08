# SMDRSS Measurement Application

To run the program start the **SMDRSS** shortcut or you can open the **SMDRSS** file in the scripts file.

File structure:
- 'config_files' - contains configurations saved in measurement app
- 'measurement_files' - contains measured data from mesurement app
- 'measurement_tones' - contains measurement tones
- 'scripts' - contains all the matlab scripts
- 'test files' - contains test scripts, which are unnecessary for the main app


# About
This application is developed by Benjamin Nimmerrichter. The aim of this application is to make aucoustic measurements as haslle free as possible.





# TODO LIST
1. check integrity setup dat
2. funkcionalita zvuku
3. generace tónů
- harm. signál LUT pro 1 periodu
- přehrání standardizovaného šumu
4. kalibrace 
- kalibrační skript
- zobrazení dat mikrofonů 
- formát aby 8 i 64 miců vypadalo nějak ok asi scrollovací list
- měření SNR
- clip_detect
- lepší výsledky korelace
5. měření
- záznam
- normalizace na -3 dBFS
6. zobrazení dat polární a sférický graf
- polární plot
- sférický plot
- zlomkooktávová analýza
- amplitudové spektrum
- export grafů ve vektorovém formátu
7. komunikace s otočnou hlavou
- spojení a test
- pohyb
