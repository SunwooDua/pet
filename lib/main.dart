import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  TextEditingController petNameController = TextEditingController();
  int energyLevel= 100;
  Timer? _hungerTimer;
  final int _winDuration = 1; // Duration in seconds (3 minutes)
  int _winCounter = 0;
  String selectedAction = 'Play';

// Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
      _updateEnergy(-20); //decrease energy by 20
    });
  }

// Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
      _updateEnergy(10); //increase energy by 10
    });
  }

// Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

//update energy
  void _updateEnergy(int change) {
    energyLevel = (energyLevel + change).clamp(0, 100);
  }

// Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  Color _getPetColor() {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String _getPetMood() {
    if (happinessLevel > 70) {
      return "Happy";
    } else if (happinessLevel >= 30) {
      return "Neutral";
    } else {
      return "Unhappy";
    }
  }

  void _setPetName() {
    setState(() {
      petName =
          petNameController.text.isEmpty ? "Your Pet" : petNameController.text;
    });
  }

  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        _updateHunger();
      });

      if (hungerLevel == 100 && happinessLevel <= 10) {
        _endGame("Game Over! Your pet is too hungry and unhappy.");
        timer.cancel();
      }

      if (happinessLevel > 80) {
        _winCounter++;
        if (_winCounter >= _winDuration) {
          _endGame("You Win! Your pet is very happy.");
          timer.cancel();
        }
      } else {
        _winCounter = 0; // Reset counter if happiness falls below 80
      }
    });
  }

  // Stop Timer
  void _stopHungerTimer() {
    if (_hungerTimer != null) {
      _hungerTimer?.cancel();
    }
  }

  // End the game and show a message
  void _endGame(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                happinessLevel = 50;
                hungerLevel = 50;
                energyLevel = 100;
                petName = "Your Pet"; // Reset the pet
                petNameController.clear();
                Navigator.of(context).pop();
              });
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _startHungerTimer(); // Start hunger timer when the app starts
  }

  @override
  void dispose() {
    _stopHungerTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Energy Level: $energyLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: energyLevel / 100,
            ),
            SizedBox(height: 16.0),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _getPetColor(),
              ),
            ),
            Text(
              'Mood: ${_getPetMood()}',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Name: $petName',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Happiness Level: $happinessLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Hunger Level: $hungerLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 32.0),
            
            DropdownButton<String>(
              value: selectedAction,
              onChanged: (String? newValue) {
                setState(() {
                  selectedAction = newValue!;
                });
              },
              items: <String>['Play', 'Feed']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            
            ElevatedButton(
              onPressed: () {
                if (selectedAction == 'Play') {
                  _playWithPet();
                } else if (selectedAction == 'Feed') {
                  _feedPet();
                }
              },
              child: Text('Confirm Action'),
            ),
            SizedBox(height: 16.0),

            Container(
              width: 200,
              height: 50,
              child: TextField(
                controller: petNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your pet\'s name',
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _setPetName,
              child: Text('Confirm Name'),
            ),
          ],
        ),
      ),
    );
  }
}
