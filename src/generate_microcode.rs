use crate::microcode::{generators::*, signals::*};

struct Operation {
    microcode: u32,
    id: String,
    tailing_empty: usize,
}

pub fn generate_microcode() -> String {
    let operations = [
        Operation {
            microcode: 0,
            id: "NOP".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: REG_WRITE_ENABLE | CONNECT_UP_TO_REG_DATA_IN,
            id: "LUI".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | alu_operation(
                    AluOp::Add,
                    AluSrcA::UpperImmediate,
                    AluSrcB::Pc,
                    AluDst::RegDataIn,
                ),
            id: "AUIPC".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_RET_ADDR_TO_REG_DATA_IN
                | jump_operation(CmpOp::True)
                | alu_operation(
                    AluOp::Add,
                    AluSrcA::JumpTypeImmediate,
                    AluSrcB::Pc,
                    AluDst::Jump,
                ),
            id: "JAL".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_RET_ADDR_TO_REG_DATA_IN
                | alu_operation(
                    AluOp::Add,
                    AluSrcA::RegOutA,
                    AluSrcB::LowerImmediate,
                    AluDst::RegDataIn,
                )
                | jump_operation(CmpOp::True),
            id: "JALR".to_string(),
            tailing_empty: 3,
        },
        Operation {
            microcode: branch_operation(CmpOp::Equal),
            id: "BEQ".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: branch_operation(CmpOp::NotEqual),
            id: "BNE".to_string(),
            tailing_empty: 2,
        },
        Operation {
            microcode: branch_operation(CmpOp::LessThan),
            id: "BLT".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: branch_operation(CmpOp::GreaterEqual),
            id: "BGE".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: branch_operation(CmpOp::LessThanUnsigned),
            id: "BLTU".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: branch_operation(CmpOp::GreaterEqualUnsigned),
            id: "BGEU".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: load_operation(),
            id: "LB".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: load_operation(),
            id: "LH".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: load_operation(),
            id: "LW".to_string(),
            tailing_empty: 1,
        },
        Operation {
            microcode: load_operation(),
            id: "LBU".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: load_operation(),
            id: "LHU".to_string(),
            tailing_empty: 2,
        },
        Operation {
            microcode: store_operation(),
            id: "SB".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: store_operation(),
            id: "SH".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: store_operation(),
            id: "SW".to_string(),
            tailing_empty: 5,
        },
        Operation {
            microcode: immediate_operation(AluOp::Add),
            id: "ADDI".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: immediate_shift_operation(AluOp::ShiftLeft),
            id: "SLLI".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: immediate_operation(AluOp::SetLessThanSigned),
            id: "SLTI".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: immediate_operation(AluOp::SetLessThanUnsigned),
            id: "SLTIU".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: immediate_operation(AluOp::Xor),
            id: "XORI".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: immediate_shift_operation(AluOp::ShiftRight),
            id: "SRLI".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: immediate_operation(AluOp::Or),
            id: "ORI".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: immediate_operation(AluOp::And),
            id: "ANDI".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: register_operation(AluOp::Add),
            id: "ADD".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: register_operation(AluOp::ShiftLeft),
            id: "SLL".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: register_operation(AluOp::SetLessThanSigned),
            id: "SLT".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: register_operation(AluOp::SetLessThanUnsigned),
            id: "SLTU".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: register_operation(AluOp::Xor),
            id: "XOR".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: register_operation(AluOp::ShiftRight),
            id: "SRL".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: register_operation(AluOp::Or),
            id: "OR".to_string(),
            tailing_empty: 0,
        },
        Operation {
            microcode: register_operation(AluOp::And),
            id: "AND".to_string(),
            tailing_empty: 5,
        },
        Operation {
            microcode: immediate_shift_operation(AluOp::ShiftRightSignExt),
            id: "SRAI".to_string(),
            tailing_empty: 2,
        },
        Operation {
            microcode: register_operation(AluOp::Subtract),
            id: "SUB".to_string(),
            tailing_empty: 4,
        },
        Operation {
            microcode: register_operation(AluOp::ShiftRightSignExt),
            id: "SRA".to_string(),
            tailing_empty: 2,
        },
    ];

    operations
        .iter()
        .flat_map(|operation| {
            std::iter::once(format!(
                "{} // {:<6}",
                &hex::encode(operation.microcode.to_be_bytes()),
                operation.id
            ))
            .chain(std::iter::repeat("00000000".to_string()).take(operation.tailing_empty))
        })
        .enumerate()
        .map(|(idx, operation)| {
            if operation == "00000000" {
                operation
            } else {
                format!("{operation} ({:#08b}) ({:#04x})", idx, idx)
            }
        })
        .collect::<Vec<_>>()
        .join("\n")
        + "\n"
}
