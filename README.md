# Designing Interactive experiences

During the course of Designing Interactive Experiences, the aim was to make an installation which would promote healthy eating. Together with a project group, we had made a physical tent in which children should grap certain physical items, such as a tree, apple or fish. You could feed these to "Bobo", a virtual bear. If you gave the items to the bear, a video would play. If Bobo had given enough healthy food, he would scare away angry poachers to save the forest.

## Arduino code

All phyiscal items contained an RFID code. Each RFID tag was linked to an object, such as an apple or fish. Depending on the scanned tag, the Arduino sends over Serial which item is given to Bobo. The serial port is conected to processing.

## Processing code

The processing code has the Serial port open. Based on the received message, it starts to play a video. There are videos for if the correct item is given, but also for when an incorrect item is given to Bobo.
To be able to mimick the tags, it is also possible to play video's using key presses.
