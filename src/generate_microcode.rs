// Main microcode signals
const CONNECT_REG_OUT_A_TO_ALU_A: u32 = 1; // s1
const CONNECT_UP_TO_ALU_A: u32 = 1 << 1; // s1
const CONNECT_JT_TO_ALU_A: u32 = 1 << 2; // s1
const CONNECT_BT_TO_ALU_A: u32 = 1 << 3; // s1
const CONNECT_REG_OUT_B_TO_ALU_B: u32 = 1 << 4; // s1
const CONNECT_LI_TO_ALU_B: u32 = 1 << 5; // s1
const CONNECT_ST_TO_ALU_B: u32 = 1 << 6; // s1
const CONNECT_INST_PC_TO_ALU_B: u32 = 1 << 7; // s1
const CONNECT_RS2_TO_ALU_B: u32 = 1 << 8; // s1
const MEM_WRITE_ENABLE: u32 = 1 << 9; // s2
const CONNECT_ALU_OUT_TO_MEM_ADDR: u32 = 1 << 10; // s2
const CONNECT_REG_OUT_B_TO_MEM_DATA: u32 = 1 << 11; // s2
const REG_WRITE_ENABLE: u32 = 1 << 12; // s3
const CONNECT_UP_TO_REG_DATA_IN: u32 = 1 << 13; // s3
const CONNECT_ALU_OUT_TO_REG_DATA_IN: u32 = 1 << 14; // s3
const CONNECT_RET_ADDR_TO_REG_DATA_IN: u32 = 1 << 15; // s3
const CONNECT_MEM_DATA_TO_REG_DATA_IN: u32 = 1 << 16; // s3
const WRITE_ALU_OUT_TO_PC_IF_BRANCH: u32 = 1 << 17; // s3
const TRUNC_BYTE: u32 = 1 << 18; // s3
const TRUNC_HALF: u32 = 1 << 19; // s3
const TRUNC_SIGNED_BYTE: u32 = 1 << 20; // s3
const TRUNC_SIGNED_HALF: u32 = 1 << 21; // s3

// Alu microcode signals
enum AluOp {
    Add,                 // 0000
    Subtract,            // 0001
    SetLessThanSigned,   // 0010
    SetLessThanUnsigned, // 0011
    Xor,                 // 0100
    Or,                  // 0101
    And,                 // 0110
    ShiftLeft,           // 0111
    ShiftRight,          // 1000
    ShiftRightSignExt,   // 1001
}

const fn decode_alu_op(alu_op: AluOp) -> u32 {
    let bits = match alu_op {
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
    };

    bits << 22
}

// Branch comparison microcode signals
enum CmpOp {
    Equal,                // 000
    NotEqual,             // 001
    LessThan,             // 010
    GreaterEqual,         // 011
    LessThanUnsigned,     // 100
    GreaterEqualUnsigned, // 101
    True,                 // 110
}

const fn decode_branch_cmp_op(cmp_op: CmpOp) -> u32 {
    let bits = match cmp_op {
        CmpOp::Equal => 0b000,
        CmpOp::NotEqual => 0b001,
        CmpOp::LessThan => 0b010,
        CmpOp::GreaterEqual => 0b011,
        CmpOp::LessThanUnsigned => 0b100,
        CmpOp::GreaterEqualUnsigned => 0b101,
        CmpOp::True => 0b110,
    };

    bits << 26
}

// Base microcode groupings
const BRANCH_BASE_MICROCODE: u32 = CONNECT_BT_TO_ALU_A
    | CONNECT_INST_PC_TO_ALU_B
    | decode_alu_op(AluOp::Add)
    | WRITE_ALU_OUT_TO_PC_IF_BRANCH;
const LOAD_BASE_MICROCODE: u32 = REG_WRITE_ENABLE
    | CONNECT_REG_OUT_A_TO_ALU_A
    | CONNECT_LI_TO_ALU_B
    | decode_alu_op(AluOp::Add)
    | CONNECT_ALU_OUT_TO_MEM_ADDR
    | CONNECT_MEM_DATA_TO_REG_DATA_IN;
const STORE_BASE_MICROCODE: u32 = MEM_WRITE_ENABLE
    | CONNECT_REG_OUT_B_TO_MEM_DATA
    | CONNECT_REG_OUT_A_TO_ALU_A
    | CONNECT_ST_TO_ALU_B
    | decode_alu_op(AluOp::Add)
    | CONNECT_ALU_OUT_TO_MEM_ADDR;
const IMMEDIATE_ALU_OP_BASE_MICROCODE: u32 = REG_WRITE_ENABLE
    | CONNECT_REG_OUT_A_TO_ALU_A
    | CONNECT_LI_TO_ALU_B
    | CONNECT_ALU_OUT_TO_REG_DATA_IN;
const IMMEDIATE_SHIFT_BASE_MICROCODE: u32 = REG_WRITE_ENABLE
    | CONNECT_REG_OUT_A_TO_ALU_A
    | CONNECT_RS2_TO_ALU_B
    | CONNECT_ALU_OUT_TO_REG_DATA_IN;
const REGISTER_ALU_OP_BASE_MICROCODE: u32 = REG_WRITE_ENABLE
    | CONNECT_REG_OUT_A_TO_ALU_A
    | CONNECT_REG_OUT_B_TO_ALU_B
    | CONNECT_ALU_OUT_TO_REG_DATA_IN;
struct Operation {
    microcode: u32,
    id: String,
}

pub fn generate_microcode() -> String {
    let operations = [
        Operation {
            microcode: 0,
            id: "null".to_string(),
        },
        Operation {
            microcode: BRANCH_BASE_MICROCODE | decode_branch_cmp_op(CmpOp::Equal),
            id: "beq".to_string(),
        },
        Operation {
            microcode: BRANCH_BASE_MICROCODE | decode_branch_cmp_op(CmpOp::NotEqual),
            id: "bne".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE | CONNECT_UP_TO_REG_DATA_IN,
            id: "lui".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_UP_TO_ALU_A
                | CONNECT_INST_PC_TO_ALU_B
                | decode_alu_op(AluOp::Add)
                | CONNECT_ALU_OUT_TO_REG_DATA_IN,
            id: "auipc".to_string(),
        },
        Operation {
            microcode: BRANCH_BASE_MICROCODE | decode_branch_cmp_op(CmpOp::LessThan),
            id: "blt".to_string(),
        },
        Operation {
            microcode: BRANCH_BASE_MICROCODE | decode_branch_cmp_op(CmpOp::GreaterEqual),
            id: "bge".to_string(),
        },
        Operation {
            microcode: BRANCH_BASE_MICROCODE | decode_branch_cmp_op(CmpOp::LessThanUnsigned),
            id: "bltu".to_string(),
        },
        Operation {
            microcode: BRANCH_BASE_MICROCODE | decode_branch_cmp_op(CmpOp::GreaterEqualUnsigned),
            id: "bgeu".to_string(),
        },
        Operation {
            microcode: LOAD_BASE_MICROCODE | TRUNC_SIGNED_BYTE,
            id: "lb".to_string(),
        },
        Operation {
            microcode: LOAD_BASE_MICROCODE | TRUNC_SIGNED_HALF,
            id: "lh".to_string(),
        },
        Operation {
            microcode: LOAD_BASE_MICROCODE,
            id: "lw".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_RET_ADDR_TO_REG_DATA_IN
                | CONNECT_JT_TO_ALU_A
                | CONNECT_INST_PC_TO_ALU_B
                | decode_alu_op(AluOp::Add)
                | WRITE_ALU_OUT_TO_PC_IF_BRANCH
                | decode_branch_cmp_op(CmpOp::True),
            id: "jal".to_string(),
        },
        Operation {
            microcode: LOAD_BASE_MICROCODE | TRUNC_BYTE,
            id: "lbu".to_string(),
        },
        Operation {
            microcode: LOAD_BASE_MICROCODE | TRUNC_HALF,
            id: "lhu".to_string(),
        },
        Operation {
            microcode: STORE_BASE_MICROCODE | TRUNC_BYTE,
            id: "sb".to_string(),
        },
        Operation {
            microcode: STORE_BASE_MICROCODE | TRUNC_HALF,
            id: "sh".to_string(),
        },
        Operation {
            microcode: STORE_BASE_MICROCODE,
            id: "sw".to_string(),
        },
        Operation {
            microcode: IMMEDIATE_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::Add),
            id: "addi".to_string(),
        },
        Operation {
            microcode: IMMEDIATE_SHIFT_BASE_MICROCODE | decode_alu_op(AluOp::ShiftLeft),
            id: "slli".to_string(),
        },
        Operation {
            microcode: IMMEDIATE_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::SetLessThanSigned),
            id: "slti".to_string(),
        },
        Operation {
            microcode: IMMEDIATE_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::SetLessThanUnsigned),
            id: "sltiu".to_string(),
        },
        Operation {
            microcode: IMMEDIATE_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::Xor),
            id: "xori".to_string(),
        },
        Operation {
            microcode: IMMEDIATE_SHIFT_BASE_MICROCODE | decode_alu_op(AluOp::ShiftRight),
            id: "srli".to_string(),
        },
        Operation {
            microcode: IMMEDIATE_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::Or),
            id: "ori".to_string(),
        },
        Operation {
            microcode: IMMEDIATE_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::And),
            id: "andi".to_string(),
        },
        Operation {
            microcode: IMMEDIATE_SHIFT_BASE_MICROCODE | decode_alu_op(AluOp::ShiftRightSignExt),
            id: "srai".to_string(),
        },
        Operation {
            microcode: REGISTER_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::Add),
            id: "add".to_string(),
        },
        Operation {
            microcode: REGISTER_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::ShiftLeft),
            id: "sll".to_string(),
        },
        Operation {
            microcode: REGISTER_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::SetLessThanSigned),
            id: "stl".to_string(),
        },
        Operation {
            microcode: REGISTER_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::SetLessThanUnsigned),
            id: "stlu".to_string(),
        },
        Operation {
            microcode: REGISTER_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::Xor),
            id: "xor".to_string(),
        },
        Operation {
            microcode: REGISTER_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::ShiftRight),
            id: "srl".to_string(),
        },
        Operation {
            microcode: REGISTER_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::Or),
            id: "or".to_string(),
        },
        Operation {
            microcode: REGISTER_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::And),
            id: "and".to_string(),
        },
        Operation {
            microcode: REGISTER_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::Subtract),
            id: "sub".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_RET_ADDR_TO_REG_DATA_IN
                | CONNECT_REG_OUT_A_TO_ALU_A
                | CONNECT_LI_TO_ALU_B
                | WRITE_ALU_OUT_TO_PC_IF_BRANCH
                | decode_branch_cmp_op(CmpOp::True),
            id: "jalr".to_string(),
        },
        Operation {
            microcode: 0,
            id: "fence".to_string(),
        },
        Operation {
            microcode: 0,
            id: "ecall".to_string(),
        },
        Operation {
            microcode: 0,
            id: "ebreak".to_string(),
        },
        Operation {
            microcode: REGISTER_ALU_OP_BASE_MICROCODE | decode_alu_op(AluOp::ShiftRightSignExt),
            id: "sra".to_string(),
        },
    ];
    operations
        .iter()
        .enumerate()
        .map(|(idx, operation)| {
            format!(
                "{} // {:<6} ({:#04X})",
                &hex::encode_upper(operation.microcode.to_be_bytes())[1..],
                operation.id,
                idx
            )
        })
        .chain((0..65 - operations.len()).map(|_| "0000000".to_string()))
        .collect::<Vec<String>>()
        .join("\n")
}
