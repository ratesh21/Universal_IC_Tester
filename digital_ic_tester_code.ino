// 7408 AND tester - direct Arduino pin mapping (custom outputs on D22,D25,D30,D33)
// Assumed mapping (change gates[] if your wiring differs):
// Gate1: out=D22, inA=D23, inB=D24
// Gate2: out=D25, inA=D26, inB=D27
// Gate3: out=D30, inA=D28, inB=D29
// Gate4: out=D33, inA=D31, inB=D32
//
// External +5V -> IC pin 14, External GND -> IC pin 7. MUST tie External GND to Arduino GND.
// Use series resistors (220-470Ω) on Arduino->IC lines and 10k pull-downs from inputs to GND.

const int SETTLE_MS = 12;

struct AndGate {
  int inA;
  int inB;
  int out;
};

// EDIT THIS ARRAY if your breadboard wiring is different.
AndGate gates[4] = {
  {22, 23, 24},  // Gate 1: inA, inB, out
  {25, 26, 27},  // Gate 2
  {29, 30, 28},  // Gate 3
  {32, 33, 31}   // Gate 4
};

void drivePin(int pin, int value) {
  pinMode(pin, OUTPUT);
  digitalWrite(pin, value ? HIGH : LOW);
}

void releasePin(int pin) {
  pinMode(pin, INPUT); // high-Z; hardware pull-down should hold LOW
}

int readPin(int pin) {
  pinMode(pin, INPUT);
  return digitalRead(pin) == HIGH ? 1 : 0;
}

bool testSingleGate(const AndGate &g) {
  // Let the IC drive its output
  releasePin(g.out);

  for (int combo = 0; combo < 4; ++combo) {
    int A = (combo >> 1) & 1;
    int B = combo & 1;

    drivePin(g.inA, A);
    drivePin(g.inB, B);

    delay(SETTLE_MS);

    int measured = readPin(g.out);
    int expected = A & B; // AND truth

    Serial.print("Inputs ");
    Serial.print(A);
    Serial.print(',');
    Serial.print(B);
    Serial.print(" -> measured: ");
    Serial.print(measured);
    Serial.print(" expected: ");
    Serial.println(expected);

    releasePin(g.inA);
    releasePin(g.inB);

    delay(6);

    if (measured != expected) {
      Serial.println("  -> MISMATCH");
      return false;
    }
  }
  return true;
}

void run7408Test() {
  bool allPassed = true;
  for (int i = 0; i < 4; ++i) {
    Serial.print("Testing Gate ");
    Serial.println(i+1);
    bool ok = testSingleGate(gates[i]);
    if (ok) {
      Serial.println("PASS\n");
    } else {
      Serial.println("FAIL\n");
      allPassed = false;
    }
  }

  if (allPassed) Serial.println("7408 IC GOOD");
  else Serial.println("7408 IC BAD");
}

void setup() {
  Serial.begin(9600);
  while(!Serial) ;

  // initialize all used pins to INPUT (high-Z)
  for (int i = 0; i < 4; ++i) {
    releasePin(gates[i].inA);
    releasePin(gates[i].inB);
    releasePin(gates[i].out);
  }

  Serial.println();
  Serial.println("7408 AND tester (custom mapping)");
  Serial.println("Ensure external +5V on IC and External GND tied to Arduino GND");
  delay(300);

  run7408Test();
}

void loop() {
  // empty - single run at startup. Add a button to rerun if you want.
}
