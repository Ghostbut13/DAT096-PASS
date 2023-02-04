-- ADC EVM board

![adcborad](https://github.com/Ghostbut13/DAT096-PASS/blob/main/Workspace/Weihan/pic/adcborad.png)



-- I2C write sequence

![adcborad](https://github.com/Ghostbut13/DAT096-PASS/blob/main/Workspace/Weihan/pic/I2C_write_sequence.png)



-- Task

1. **Apply Power to Device:**
   a. Power up the IOVDD, AVDD, and BSTVDD power supplies, keeping the SHDNZ pin voltage low

   b. The device now goes into hardware shutdown mode (ultra-low-power mode < 1 μA)

2. **Transition From Hardware Shutdown Mode to Sleep Mode (or Software Shutdown Mode):**
   a. Release SHDNZ only when the IOVDD, AVDD, and BSTVDD power supplies settle to the steady-state
   operating voltage

   b. Wait for at least 1 ms to allow the device to initialize the internal registers

   c. The device now goes into sleep mode (low-power mode < 20 μA)

3. **Transition From Sleep Mode to Active Mode Whenever Required for the Record Operation:**
   a. Wake-up the device by writing P0_R2 to disable sleep mode

   b. Wait for at least 1ms to allow the device internal wake-up sequence to complete

   c. Override the default configuration registers or programmable coefficients value as required (optional)

   d. Enable all desired input channels by writing P0_R115

   e. Enable all desired audio serial interface output channels by writing P0_R116

   f. Power-up the ADC, MICBIAS, and PLL by writing P0_R117

   g. Apply FSYNC and BCLK with the desired output sample rates and the BCLK to FSYNC ratio

   This specific step can be done at any point in the sequence after step A

   See the Phase-Locked Loop (PLL) and Clock Generation section for the supported sample rates and the BCLK to FSYNC ratio

   h. The device recording data are now sent to the host processor via the TDM audio serial data bus

   i. Wait for at least 10 ms to allow the MICBIAS to power up

   j. Enable the fault diagnostics for all desired input channels by writing P0_R100

4. **Transition From Active Mode to Sleep Mode (Again) as Required in the System Low Power:**
   a. Disable the fault diagnostics for all desired input channels by writing P0_R100

   b. Go to sleep mode by writing P0_R2 to enable sleep mode

   c. Wait at least 20 ms to allow the volume to gradually ramp down and for all blocks to power down

   d. Read P0_R119 to check the device shutdown and sleep mode status

   e. If the device P0_R119_D7 status bit is 1'b1, then stop FSYNC and BCLK in the system

   f. The device now goes into sleep mode (low-power mode < 20 μA) and retains all register values

5. **Transition From Sleep Mode to Active Mode (Again) as Required for the Record Operation:**
   a. Wake-up the device by writing P0_R2 to disable sleep mode

   b. Wait for at least 1 ms to allow the device internal wake-up sequence to complete

   c. Apply FSYNC and BCLK with the desired output sample rates and BCLK to FSYNC ratio

   d. The device recording data are now sent to the host processor via the TDM audio serial data bus

   e. Wait for at least 10 ms to allow the MICBIAS to power up

   f. Enable the fault diagnostics for all desired input channels by writing P0_R100

6. **Repeat Step 4 and Step 5 as Required for Mode Transitions**

7. **Assert the SHDNZ Pin Low to Enter Hardware Shutdown Mode (Again) at Any Time**

8. **Follow Step 2 Onwards to Exit Hardware Shutdown Mode (Again)**