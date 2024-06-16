--
--  Copyright (C) 2024, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Restrictions (No_Elaboration_Code);

with A0B.ATSAM3X8E.SVD.USART; use A0B.ATSAM3X8E.SVD.USART;

package body A0B.ATSAM3X8E.USART is

   ------------------
   -- On_Interrupt --
   ------------------

   procedure On_Interrupt (Self : in out USART_Controller'Class) is
      use type System.Address;

      State : constant USART0_CSR_Register := Self.Peripheral.CSR;
      Mask  : constant USART0_IMR_Register := Self.Peripheral.IMR;

   begin
      if State.RXRDY and Mask.RXRDY then
         if Self.Receive_Buffer /= System.Null_Address then
            declare
               Data : A0B.Types.Unsigned_8
                 with Import,
                      Convention => Ada,
                      Address    => Self.Receive_Buffer;

            begin
               Data := A0B.Types.Unsigned_8 (Self.Peripheral.RHR.RXCHR);
            end;

         else
            declare
               Data : A0B.Types.Unsigned_8 with Unreferenced;

            begin
               Data := A0B.Types.Unsigned_8 (Self.Peripheral.RHR.RXCHR);
               --  Read register to clear RXRDY interrupt status flag.
            end;
         end if;

         Self.Peripheral.CR := (TXDIS => True, others => <>);
         Self.Busy := False;

         A0B.Callbacks.Emit (Self.Finished_Callback);
      end if;

      if State.TXRDY and Mask.TXRDY then
         declare
            Data : constant A0B.Types.Unsigned_8
              with Import, Convention => Ada, Address => Self.Transmit_Buffer;

         begin
            Self.Peripheral.THR :=
              (TXCHR  => USART0_THR_TXCHR_Field (Data),
               others => <>);
            Self.Peripheral.CR := (TXDIS => True, others => <>);
         end;
      end if;
   end On_Interrupt;

   --------------------
   -- Release_Device --
   --------------------

   overriding procedure Release_Device (Self : in out SPI_Slave_Device) is
   begin
      Self.Controller.Peripheral.CR := (RTSDIS => True, others => <>);
   end Release_Device;

   -------------------
   -- Select_Device --
   -------------------

   overriding procedure Select_Device (Self : in out SPI_Slave_Device) is
   begin
      Self.Controller.Peripheral.CR := (RTSEN => True, others => <>);
   end Select_Device;

   --------------
   -- Transfer --
   --------------

   overriding procedure Transfer
     (Self              : in out SPI_Slave_Device;
      Transmit_Buffer   : aliased A0B.Types.Unsigned_8;
      Receive_Buffer    : aliased out A0B.Types.Unsigned_8;
      Finished_Callback : A0B.Callbacks.Callback;
      Success           : in out Boolean) is
   begin
      if not Success or Self.Controller.Busy then
         Success := False;

         return;
      end if;

      Self.Controller.Busy              := True;
      Self.Controller.Transmit_Buffer   := Transmit_Buffer'Address;
      Self.Controller.Receive_Buffer    := Receive_Buffer'Address;
      Self.Controller.Finished_Callback := Finished_Callback;

      Self.Controller.Peripheral.CR :=
        (RXEN   => True,
         TXEN   => True,
         others => <>);
      --  Enable receiver and transmitter.

      Self.Controller.Peripheral.IER :=
        (RXRDY  => True,
         TXRDY  => True,
         others => <>);
      --  Enable RXRDY and TXRDY interrupts.
   end Transfer;

   --------------
   -- Transmit --
   --------------

   overriding procedure Transmit
     (Self              : in out SPI_Slave_Device;
      Transmit_Buffer   : aliased A0B.Types.Unsigned_8;
      Finished_Callback : A0B.Callbacks.Callback;
      Success           : in out Boolean) is
   begin
      if not Success or Self.Controller.Busy then
         Success := False;

         return;
      end if;

      Self.Controller.Busy              := True;
      Self.Controller.Transmit_Buffer   := Transmit_Buffer'Address;
      Self.Controller.Receive_Buffer    := System.Null_Address;
      Self.Controller.Finished_Callback := Finished_Callback;

      Self.Controller.Peripheral.CR :=
        (RXEN   => True,
         TXEN   => True,
         others => <>);
      --  Enable receiver and transmitter.

      Self.Controller.Peripheral.IER :=
        (RXRDY  => True,
         TXRDY  => True,
         others => <>);
      --  Enable RXRDY and TXRDY interrupts.
   end Transmit;

end A0B.ATSAM3X8E.USART;
