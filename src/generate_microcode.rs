const CONNECT_REG_OUT_A_TO_ALU_A: u32 = 0b00000000000000000000000000000001; // s1 (2, 5) (0)
const CONNECT_UP_TO_ALU_A: u32 = 0b00000000000000000000000000000010; // s1 (13) (1)
const CONNECT_JT_TO_ALU_A: u32 = 0b00000000000000000000000000000100; // s1 (16) (2)
const CONNECT_BT_TO_ALU_A: u32 = 0b00000000000000000000000000001000; // s1 (18) (3)
const CONNECT_REG_OUT_B_TO_ALU_B: u32 = 0b00000000000000000000000000010000; // s1 (8, 7) (4)
const CONNECT_LI_TO_ALU_B: u32 = 0b00000000000000000000000000100000; // s1 (3) (5)
const CONNECT_ST_TO_ALU_B: u32 = 0b00000000000000000000000001000000; // s1 (12) (6)
const CONNECT_INST_PC_TO_ALU_B: u32 = 0b00000000000000000000000010000000; // s1 (14) (7)
const CONNECT_RS2_TO_ALU_B: u32 = 0b00000000000000000000000100000000; // s1 (nul) (8)
const MEM_WRITE_ENABLE: u32 = 0b00000000000000000000001000000000; // s2 (10) (9)
const CONNECT_ALU_OUT_TO_MEM_ADDR: u32 = 0b00000000000000000000010000000000; // s2 (6) (10)
const CONNECT_BUF_REG_OUT_B_TO_MEM_DATA: u32 = 0b00000000000000000000100000000000; // s2 (11, 7) (11)
const REG_WRITE_ENABLE: u32 = 0b00000000000000000001000000000000; // s3 (1) (12)
const CONNECT_UP_TO_REG_DATA_IN: u32 = 0b00000000000000000010000000000000; // s3(0) (13)
const CONNECT_BUF_ALU_OUT_TO_REG_DATA_IN: u32 = 0b00000000000000000100000000000000; // s3 (4) (14)
const CONNECT_MEM_DATA_TO_REG_DATA_IN: u32 = 0b00000000000000001000000000000000; // s3 (9) (15)
const CONNECT_RET_ADDR_TO_REG_DATA_IN: u32 = 0b00000000000000010000000000000000; // s3 (15) (16)
const WRITE_BUF_ALU_OUT_TO_PC_IF_BRANCH: u32 = 0b00000000000000100000000000000000; // s3 (17) (17)

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

fn decode_alu_op(alu_op: AluOp) -> u32 {
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

    bits << 18
}

enum CmpOp {
    Equal,                // 000
    NotEqual,             // 001
    LessThan,             // 010
    GreaterEqual,         // 011
    LessThanUnsigned,     // 100
    GreaterEqualUnsigned, // 101
    True,                 // 110
}

fn decode_branch_cmp_op(cmp_op: CmpOp) -> u32 {
    let bits = match cmp_op {
        CmpOp::Equal => 0b000,
        CmpOp::NotEqual => 0b001,
        CmpOp::LessThan => 0b010,
        CmpOp::GreaterEqual => 0b011,
        CmpOp::LessThanUnsigned => 0b100,
        CmpOp::GreaterEqualUnsigned => 0b101,
        CmpOp::True => 0b110,
    };

    bits << 22
}

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
            microcode: CONNECT_BT_TO_ALU_A
                | CONNECT_INST_PC_TO_ALU_B
                | decode_alu_op(AluOp::Add)
                | WRITE_BUF_ALU_OUT_TO_PC_IF_BRANCH
                | decode_branch_cmp_op(CmpOp::Equal),
            id: "beq".to_string(),
        },
        Operation {
            microcode: 0,
            id: "bne".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE | CONNECT_UP_TO_REG_DATA_IN,
            id: "lui".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_INST_PC_TO_ALU_B
                | CONNECT_UP_TO_ALU_A
                | CONNECT_BUF_ALU_OUT_TO_REG_DATA_IN
                | decode_alu_op(AluOp::Add),
            id: "auipc".to_string(),
        },
        Operation {
            microcode: 0,
            id: "blt".to_string(),
        },
        Operation {
            microcode: 0,
            id: "bge".to_string(),
        },
        Operation {
            microcode: 0,
            id: "bltu".to_string(),
        },
        Operation {
            microcode: 0,
            id: "bgeu".to_string(),
        },
        Operation {
            microcode: 0,
            id: "lb".to_string(),
        },
        Operation {
            microcode: 0,
            id: "lh".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_REG_OUT_A_TO_ALU_A
                | CONNECT_LI_TO_ALU_B
                | decode_alu_op(AluOp::Add)
                | CONNECT_ALU_OUT_TO_MEM_ADDR
                | CONNECT_MEM_DATA_TO_REG_DATA_IN,
            id: "lw".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_RET_ADDR_TO_REG_DATA_IN
                | CONNECT_JT_TO_ALU_A
                | CONNECT_INST_PC_TO_ALU_B
                | decode_alu_op(AluOp::Add)
                | WRITE_BUF_ALU_OUT_TO_PC_IF_BRANCH
                | decode_branch_cmp_op(CmpOp::True),
            id: "jal".to_string(),
        },
        Operation {
            microcode: 0,
            id: "lbu".to_string(),
        },
        Operation {
            microcode: 0,
            id: "lhu".to_string(),
        },
        Operation {
            microcode: 0,
            id: "sb".to_string(),
        },
        Operation {
            microcode: 0,
            id: "sh".to_string(),
        },
        Operation {
            microcode: MEM_WRITE_ENABLE
                | CONNECT_REG_OUT_A_TO_ALU_A
                | CONNECT_ST_TO_ALU_B
                | decode_alu_op(AluOp::Add)
                | CONNECT_ALU_OUT_TO_MEM_ADDR
                | CONNECT_BUF_REG_OUT_B_TO_MEM_DATA,
            id: "sw".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_REG_OUT_A_TO_ALU_A
                | CONNECT_LI_TO_ALU_B
                | decode_alu_op(AluOp::Add)
                | CONNECT_BUF_ALU_OUT_TO_REG_DATA_IN,
            id: "addi".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_REG_OUT_A_TO_ALU_A
                | CONNECT_RS2_TO_ALU_B
                | decode_alu_op(AluOp::ShiftLeft)
                | CONNECT_BUF_ALU_OUT_TO_REG_DATA_IN,
            id: "slli".to_string(),
        },
        Operation {
            microcode: 0,
            id: "slti".to_string(),
        },
        Operation {
            microcode: 0,
            id: "sltiu".to_string(),
        },
        Operation {
            microcode: 0,
            id: "xori".to_string(),
        },
        Operation {
            microcode: 0,
            id: "srli".to_string(),
        },
        Operation {
            microcode: 0,
            id: "ori".to_string(),
        },
        Operation {
            microcode: 0,
            id: "andi".to_string(),
        },
        Operation {
            microcode: 0,
            id: "srai".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_REG_OUT_A_TO_ALU_A
                | CONNECT_REG_OUT_B_TO_ALU_B
                | decode_alu_op(AluOp::Add),
            id: "add".to_string(),
        },
        Operation {
            microcode: 0,
            id: "sll".to_string(),
        },
        Operation {
            microcode: 0,
            id: "stl".to_string(),
        },
        Operation {
            microcode: 0,
            id: "stlu".to_string(),
        },
        Operation {
            microcode: 0,
            id: "xor".to_string(),
        },
        Operation {
            microcode: 0,
            id: "srl".to_string(),
        },
        Operation {
            microcode: 0,
            id: "or".to_string(),
        },
        Operation {
            microcode: 0,
            id: "and".to_string(),
        },
        Operation {
            microcode: 0,
            id: "sub".to_string(),
        },
        Operation {
            microcode: REG_WRITE_ENABLE
                | CONNECT_RET_ADDR_TO_REG_DATA_IN
                | CONNECT_REG_OUT_A_TO_ALU_A
                | CONNECT_LI_TO_ALU_B
                | WRITE_BUF_ALU_OUT_TO_PC_IF_BRANCH
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
            microcode: 0,
            id: "sra".to_string(),
        },
    ];
    operations
        .iter()
        .enumerate()
        .map(|(idx, operation)| {
            format!(
                "{} // {} ({:#04x})",
                hex::encode(operation.microcode.to_be_bytes())[1..].to_string(),
                operation.id,
                idx
            )
        })
        .chain((0..65 - operations.len()).map(|_| "0000000".to_string()))
        .collect::<Vec<String>>()
        .join("\n")
}
