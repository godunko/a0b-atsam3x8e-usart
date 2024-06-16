--
--  Copyright (C) 2024, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Restrictions (No_Elaboration_Code);

pragma Ada_2022;

with A0B.ARMv7M.NVIC_Utilities; use A0B.ARMv7M.NVIC_Utilities;
with A0B.ATSAM3X8E.SVD.PMC;     use A0B.ATSAM3X8E.SVD.PMC;
with A0B.ATSAM3X8E.SVD.USART;   use A0B.ATSAM3X8E.SVD.USART;

package body A0B.ATSAM3X8E.USART.Generic_USART1_SPI is

   procedure USART1_Handler
     with Export, Convention => C, External_Name => "USART1_Handler";

   ---------------
   -- Configure --
   ---------------

   procedure Configure (Self : in out USART1_SPI_Controller'Class) is
      Value : PMC_PCER0_PID_Field_Array := [others => False];

   begin
      Value (Integer (Self.Identifier)) := True;

      PMC_Periph.PMC_PCER0 :=
        (PID    => (As_Array => True, Arr => Value),
         others => <>);

      --  Reset

      Self.Peripheral.MR   := (others => <>);
      Self.Peripheral.RTOR := (others => <>);
      Self.Peripheral.TTGR := (others => <>);

      Self.Peripheral.CR   := (RSTTX => True, TXDIS => True, others => <>);
      Self.Peripheral.CR   := (RSTRX => True, RXDIS => True, others => <>);
      Self.Peripheral.CR   := (RSTSTA => True, others => <>);
      Self.Peripheral.CR   := (RTSDIS => True, others => <>);

      --  Configure

      Self.Peripheral.MR :=
        (USART_MODE => SPI_MASTER,
         USCLKS     => MCK,
         CHRL       => Val_8_BIT,
         SYNC       => False,  --  CPHA
         --  PAR            => MR_PAR_Field,
         --  NBSTOP         => MR_NBSTOP_Field,
         CHMODE     => NORMAL,
         MSBF       => True,   --  CPOL
         --  MODE9          => Boolean,
         CLKO       => True,
         --  OVER           => Boolean,
         INACK      => False,  --  WRDBT
         --  DSNACK         => Boolean,
         --  VAR_SYNC       => Boolean,
         --  INVDATA        => Boolean,
         --  MAX_ITERATION  => USART0_MR_MAX_ITERATION_Field,
         --  Reserved_27_27 => A0B.Types.SVD.Bit,
         --  FILTER         => Boolean,
         --  MAN            => Boolean,
         --  MODSYNC        => Boolean,
         --  ONEBIT         => Boolean))
         others     => <>);
      --  Self.Peripheral.MR_SPI_MODE :=
      --    (USART_MODE => SPI_MASTER,  --  + +
      --     USCLKS     => MCK,         --  + +
      --     CHRL       => Val_8_BIT,   --  + +
      --     CPHA       => True,              +
      --     CPOL       => True,              +
      --     WRDBT      => False,
      --     Reserved_17_19 =>
      --     others     => <>);
      Self.Peripheral.BRGR :=
        (CD     => 168,
         FP     => 0,
         others => <>);
      --  Self.Peripheral.RTOR :=
      --    (TO     => 0,
      --     others => <>);
      --  Self.Peripheral.TTGR :=
      --    (TG     => 0,
      --     others => <>);

      MISO.Configure_RXD1 (Pullup => True);
      MOSI.Configure_TXD1 (Pullup => True);
      SCK.Configure_SCK1 (Pullup => True);
      NSS.Configure_RTS1 (Pullup => True);

      Clear_Pending (A0B.ARMv7M.External_Interrupt_Number (Self.Identifier));
      Enable_Interrupt
        (A0B.ARMv7M.External_Interrupt_Number (Self.Identifier));
   end Configure;

   --------------------
   -- USART1_Handler --
   --------------------

   procedure USART1_Handler is
   begin
      On_Interrupt (USART1_SPI);
   end USART1_Handler;

end A0B.ATSAM3X8E.USART.Generic_USART1_SPI;
