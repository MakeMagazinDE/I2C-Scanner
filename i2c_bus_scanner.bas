; I2C-Bus-Scanner
#terminal 4800

symbol value = b0 ; muss in b0 sein, wegen Bitauswertung
symbol nibble = b1
symbol addr = b2
symbol cnt = b3

symbol SSP1BUF = 0x91  ; I2C-Senderegister SSP1BUF bei Picaxe 08M2
symbol SSP1STAT = 0x94 ; I2C-Statusregister SSP1STAT bei Picaxe 08M2

main:     
   pause 3000   ; Wartezeit, damit Terminal nach Programmiervorgang bereit ist
   sertxd (cr, lf, "*********** I2C Bus Scanner ***********", cr, lf)
   cnt = 0  
   for addr = %00000010 to %11111110 step 2    ; R/W in bit0 ist immer 0
      hi2csetup i2cmaster,addr,i2cslow,i2cbyte ; I2C-Adresse setzen
      pokesfr SSP1STAT, 0x40 ; SMBus mode aktivieren => an den I2C Pins
                             ; wird bereits ab 2,1V ein HIGH-Pegel erkannt
      hi2cout (0) ; Nullbyte senden
                  ; Wenn auf die I2C-Adresse kein ACK erfolgt, bricht hi2cout ab
                  ; und sendet das Nullbyte nicht. In SSP1BUF steht immer das
                  ; zuletzt gesendete Datenbyte, bei fehlendem ACK also die
                  ; I2C-Adresse.
      peeksfr SSP1BUF,value ; SSP1BUF lesen
      if value = 0 then     ; wenn Null, dann wurde hi2cout komplett ausgef?hrt,
                            ; d.h. auf der I2C-Adresse kam ein ACK eines Slaves
         value = addr
         inc cnt
         sertxd ("I2C-Adresse: ")
         sertxd (#bit7,#bit6,#bit5,#bit4," ",#bit3,#bit2,#bit1,#bit0, " (bin)   ")
         gosub printHex
         sertxd (" (hex)", cr, lf)
      else
         if value <> addr then
            sertxd ("Fehler: ",#value, cr, lf) ; dies sollte nie passieren
         endif
      endif
   next addr
   sertxd ("Anzahl gefundener I2C-Teilnehmer: ", #cnt, cr,lf)
goto main


printHex:
   nibble = value / 16
   gosub printNibble                 
   nibble = value & 0xF
   gosub printNibble                 
return


printNibble:
   nibble = nibble + "0"
   if nibble > "9" then             
      nibble = nibble + 7            ; dezimal 10-15 entspricht hex A-F
   endif
   sertxd(nibble)
return
