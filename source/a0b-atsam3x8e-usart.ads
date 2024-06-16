--
--  Copyright (C) 2024, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Restrictions (No_Elaboration_Code);

private with System;

private with A0B.Callbacks;
with A0B.SPI;
with A0B.ATSAM3X8E.SVD.USART;
private with A0B.Types;

package A0B.ATSAM3X8E.USART
  with Preelaborate
is

   type USART_Controller
     (Peripheral : not null access A0B.ATSAM3X8E.SVD.USART.USART_Peripheral;
      Identifier : Peripheral_Identifier) is tagged limited private;

   type SPI_Slave_Device
     (Controller : not null access USART_Controller'Class) is
--        NPCS : not null access A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin'Class) is
     limited new A0B.SPI.SPI_Slave_Device with private;

--     procedure Configure (Self : in out SPI_Slave_Device'Class);

   overriding procedure Select_Device (Self : in out SPI_Slave_Device);

   overriding procedure Release_Device (Self : in out SPI_Slave_Device);

private

   type USART_Controller
     (Peripheral : not null access A0B.ATSAM3X8E.SVD.USART.USART_Peripheral;
      Identifier : Peripheral_Identifier)
--     --    is abstract limited new A0B.SPI.SPI_Bus with
     is tagged limited
   record
      Busy              : Boolean := False with Volatile;
      --  XXX State of the controller must be protected from interrupt
      --  preemption and task switch.
      Transmit_Buffer   : System.Address;
      Receive_Buffer    : System.Address;
      Finished_Callback : A0B.Callbacks.Callback;
--        Selected_Device : access SPI_Slave_Device'Class;
   end record;

   type SPI_Slave_Device
     (Controller : not null access USART_Controller'Class) is
--        NPCS : not null access A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin'Class) is
     limited new A0B.SPI.SPI_Slave_Device with
   record
      null;
   end record;

   overriding procedure Transfer
     (Self              : in out SPI_Slave_Device;
      Transmit_Buffer   : aliased A0B.Types.Unsigned_8;
      Receive_Buffer    : aliased out A0B.Types.Unsigned_8;
      Finished_Callback : A0B.Callbacks.Callback;
      Success           : in out Boolean);

   overriding procedure Transmit
     (Self              : in out SPI_Slave_Device;
      Transmit_Buffer   : aliased A0B.Types.Unsigned_8;
      Finished_Callback : A0B.Callbacks.Callback;
      Success           : in out Boolean);

   procedure On_Interrupt (Self : in out USART_Controller'Class);

end A0B.ATSAM3X8E.USART;
