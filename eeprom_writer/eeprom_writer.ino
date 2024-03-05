void setup()
{
    Serial.begin(9600);
    Serial.print("start");
}

uint32_t addr;

void loop()
{
    while (Serial.available() != 0) {
        uint8_t buffer[1];
        Serial.readBytes(buffer, 1);

        // write

        addr += 1;
    }
}
