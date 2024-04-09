use super::signals::*;

#[derive(PartialEq, Clone, Copy)]
pub enum AluSrcA {
    UpperImmediate,
    JumpTypeImmediate,
    BranchTypeImmediate,
    RegOutA,
}

impl From<AluSrcA> for Option<PreAluASelect> {
    fn from(value: AluSrcA) -> Self {
        match value {
            AluSrcA::UpperImmediate => Some(PreAluASelect::Upper),
            AluSrcA::JumpTypeImmediate => Some(PreAluASelect::Jump),
            AluSrcA::BranchTypeImmediate => Some(PreAluASelect::Branch),
            AluSrcA::RegOutA => None,
        }
    }
}

#[derive(PartialEq, Clone, Copy)]
pub enum AluSrcB {
    LowerImmediate,
    StoreTypeImmediate,
    Pc,
    Rs2,
    RegOutB,
}

impl From<AluSrcB> for Option<PreAluBSelect> {
    fn from(value: AluSrcB) -> Self {
        match value {
            AluSrcB::LowerImmediate => Some(PreAluBSelect::LowerImmediate),
            AluSrcB::StoreTypeImmediate => Some(PreAluBSelect::StoreTypeImmediate),
            AluSrcB::Pc => Some(PreAluBSelect::Pc),
            AluSrcB::Rs2 => Some(PreAluBSelect::Rs2),
            AluSrcB::RegOutB => None,
        }
    }
}

pub enum AluDst {
    MemAddr,
    RegDataIn,
    Jump,
}

type OptionPreAluASelect = Option<PreAluASelect>;
type OptionPreAluBSelect = Option<PreAluBSelect>;

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

    signal |= match OptionPreAluASelect::from(src_a) {
        Some(pre_select) => {
            (match pre_select {
                PreAluASelect::Upper => 0b00,
                PreAluASelect::Jump => 0b01,
                PreAluASelect::Branch => 0b10,
            } << 2)
                | CONNECT_PRE_ALU_A_TO_ALU_A
        }
        None => 0,
    };

    signal |= match OptionPreAluBSelect::from(src_b) {
        Some(pre_select) => {
            (match pre_select {
                PreAluBSelect::LowerImmediate => 0b00,
                PreAluBSelect::StoreTypeImmediate => 0b01,
                PreAluBSelect::Pc => 0b10,
                PreAluBSelect::Rs2 => 0b11,
            } << 4)
                | CONNECT_PRE_ALU_B_TO_ALU_B
        }
        None => 0,
    };

    signal |= match dst {
        AluDst::MemAddr => CONNECT_ALU_OUT_TO_MEM_ADDR,
        AluDst::RegDataIn => CONNECT_ALU_OUT_TO_REG_DATA_IN,
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
    ) | CONNECT_MEM_DATA_OUT_TO_REG_DATA_IN
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
