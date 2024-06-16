--
--  Copyright (C) 2024, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Restrictions (No_Elaboration_Code);

with A0B.ATSAM3X8E.PIO;

generic
   MISO : in out A0B.ATSAM3X8E.PIO.RXD1_Line'Class;
   MOSI : in out A0B.ATSAM3X8E.PIO.TXD1_Line'Class;
   SCK  : in out A0B.ATSAM3X8E.PIO.SCK1_Line'Class;
   NSS  : in out A0B.ATSAM3X8E.PIO.RTS1_Line'Class;

package A0B.ATSAM3X8E.USART.Generic_USART1_SPI
  with Preelaborate
is

   type USART1_SPI_Controller is new USART_Controller with null record;

   procedure Configure (Self : in out USART1_SPI_Controller'Class);

   USART1_SPI : aliased USART1_SPI_Controller
     (Peripheral => A0B.ATSAM3X8E.SVD.USART.USART1_Periph'Access,
      Identifier => Universal_Synchronous_Asynchronous_Receiver_Transmitter_1);

end A0B.ATSAM3X8E.USART.Generic_USART1_SPI;
