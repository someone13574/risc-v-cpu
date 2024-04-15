use super::signals::*;

pub enum WritebackSelect {
    UpperImmediate,
    AluOut,
    ReturnAddr,
    MemData,
}

impl WritebackSelect {
    pub fn decode(&self) -> u32 {
        match self {
            WritebackSelect::UpperImmediate => USE_PRE_WB_OVER_MEM_DATA,
            WritebackSelect::AluOut => (0b01 << 19) & USE_PRE_WB_OVER_MEM_DATA,
            WritebackSelect::ReturnAddr => (0b10 << 19) & USE_PRE_WB_OVER_MEM_DATA,
            WritebackSelect::MemData => 0,
        }
    }
}

#[derive(PartialEq)]
pub enum AluSrcA {
    UpperImmediate,
    JumpTypeImmediate,
    BranchTypeImmediate,
    RegOutA,
}

impl AluSrcA {
    pub fn decode(&self) -> u32 {
        match self {
            AluSrcA::UpperImmediate => 0,
            AluSrcA::JumpTypeImmediate => 0b01 << 2,
            AluSrcA::BranchTypeImmediate => 0b10 << 2,
            AluSrcA::RegOutA => 0b11 << 2,
        }
    }
}

#[derive(PartialEq)]
pub enum AluSrcB {
    LowerImmediate,
    StoreTypeImmediate,
    Pc,
    Rs2,
    RegOutB,
}

impl AluSrcB {
    pub fn decode(&self) -> u32 {
        match self {
            AluSrcB::LowerImmediate => 0,
            AluSrcB::StoreTypeImmediate => 0b001 << 4,
            AluSrcB::Pc => 0b010 << 4,
            AluSrcB::Rs2 => 0b011 << 4,
            AluSrcB::RegOutB => 0b100 << 4,
        }
    }
}

pub enum AluDst {
    MemAddr,
    RegDataIn,
    Jump,
}

pub fn alu_operation(operation: AluOp, src_a: AluSrcA, src_b: AluSrcB, dst: AluDst) -> u32 {
    let mut signal = match operation {
        AluOp::Add => 0b0000,
        AluOp::Subtract => 0b0001,
        AluOp::SetLessThanSigned => 0b0010,
        AluOp::SetLessThanUnsigned => 0b0011,
        AluOp::Xor => 0b0100,
        AluOp::Or => 0b0101,
        AluOp::And => 0b0110,
        AluOp::ShiftLeft => 0b0111,
        AluOp::ShiftRight => 0b1000,
        AluOp::ShiftRightSignExt => 0b1001,
    } << 8;

    signal |= src_a.decode();
    signal |= src_b.decode();

    signal |= match dst {
        AluDst::MemAddr => CONNECT_ALU_OUT_TO_MEM_ADDR,
        AluDst::RegDataIn => WritebackSelect::AluOut.decode(),
        AluDst::Jump => 0,
    };

    signal |= if src_a == AluSrcA::RegOutA {
        CHECK_RS1_DEP
    } else {
        0
    };
    signal |= if src_b == AluSrcB::RegOutB {
        CHECK_RS2_DEP
    } else {
        0
    };

    signal
}

pub fn jump_operation(operation: CmpOp) -> u32 {
    let mut signal = match operation {
        CmpOp::Equal => 0b001,
        CmpOp::NotEqual => 0b010,
        CmpOp::LessThan => 0b011,
        CmpOp::GreaterEqual => 0b100,
        CmpOp::LessThanUnsigned => 0b101,
        CmpOp::GreaterEqualUnsigned => 0b110,
        CmpOp::True => 0b111,
    } << 12;

    signal |= JUMP_IF_BRANCH;

    signal
}

pub fn branch_operation(comparison: CmpOp) -> u32 {
    alu_operation(
        AluOp::Add,
        AluSrcA::BranchTypeImmediate,
        AluSrcB::Pc,
        AluDst::Jump,
    ) | jump_operation(comparison)
}

pub fn load_operation() -> u32 {
    alu_operation(
        AluOp::Add,
        AluSrcA::RegOutA,
        AluSrcB::LowerImmediate,
        AluDst::MemAddr,
    ) | WritebackSelect::MemData.decode()
        | MEM_IN_USE
}

pub fn store_operation() -> u32 {
    alu_operation(
        AluOp::Add,
        AluSrcA::RegOutA,
        AluSrcB::StoreTypeImmediate,
        AluDst::MemAddr,
    ) | MEM_WRITE_ENABLE
        | MEM_IN_USE
}

pub fn immediate_operation(operation: AluOp) -> u32 {
    REG_WRITE_ENABLE
        | alu_operation(
            operation,
            AluSrcA::RegOutA,
            AluSrcB::LowerImmediate,
            AluDst::RegDataIn,
        )
}

pub fn immediate_shift_operation(operation: AluOp) -> u32 {
    REG_WRITE_ENABLE | alu_operation(operation, AluSrcA::RegOutA, AluSrcB::Rs2, AluDst::RegDataIn)
}

pub fn register_operation(operation: AluOp) -> u32 {
    REG_WRITE_ENABLE
        | alu_operation(
            operation,
            AluSrcA::RegOutA,
            AluSrcB::RegOutB,
            AluDst::RegDataIn,
        )
}
