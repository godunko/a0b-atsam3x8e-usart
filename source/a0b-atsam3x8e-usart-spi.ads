--
--  Copyright (C) 2024, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  pragma Restrictions (No_Elaboration_Code);

with A0B.ATSAM3X8E.PIO.PIOA;

package A0B.ATSAM3X8E.USART.SPI
  with Preelaborate
is

   type USART_SPI_Controller
     (Peripheral   : not null access A0B.ATSAM3X8E.SVD.USART.USART_Peripheral;
      Identifier   : Peripheral_Identifier;
      --  Interrupt     : A0B.ARMv7M.External_Interrupt_Number;
      TXD          : not null access A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin'Class;
      TXD_Function : A0B.ATSAM3X8E.Line_Function;
      RXD          : not null access A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin'Class;
      RXD_Function : A0B.ATSAM3X8E.Line_Function;
      SCK          : not null access A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin'Class;
      SCK_Function : A0B.ATSAM3X8E.Line_Function;
      RTS          : not null access A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin'Class;
      RTS_Function : A0B.ATSAM3X8E.Line_Function) is
     new USART_Controller (Peripheral => Peripheral, Identifier => Identifier)
       with null record;

   procedure Configure (Self : in out USART_SPI_Controller'Class);

   subtype USART1_SPI_Controller is
     USART_SPI_Controller
     (Peripheral   => A0B.ATSAM3X8E.SVD.USART.USART1_Periph'Access,
      Identifier   =>
        Universal_Synchronous_Asynchronous_Receiver_Transmitter_1,
      TXD          => A0B.ATSAM3X8E.PIO.PIOA.PA13'Access,
      TXD_Function => A0B.ATSAM3X8E.TXD1,
      RXD          => A0B.ATSAM3X8E.PIO.PIOA.PA12'Access,
      RXD_Function => A0B.ATSAM3X8E.RXD1,
      SCK          => A0B.ATSAM3X8E.PIO.PIOA.PA16'Access,
      SCK_Function => A0B.ATSAM3X8E.SCK1,
      RTS          => A0B.ATSAM3X8E.PIO.PIOA.PA14'Access,
      RTS_Function => A0B.ATSAM3X8E.RTS1);

   USART1_SPI : aliased USART1_SPI_Controller;

end A0B.ATSAM3X8E.USART.SPI;
