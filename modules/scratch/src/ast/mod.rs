#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct Span {
    pub begin: usize,
    pub end: usize,
}

impl Span {
    pub fn new(begin: usize, end: usize) -> Self {
        Self { begin, end }
    }
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct BlockDefinition {
    pub span: Span,
    pub id: String,
    pub labels: Vec<String>,
    pub args: Vec<String>,
    pub body: Vec<Instruction>,
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct CostumeDefinition {
    pub span: Span,
    pub id: String,
    pub filename: String,
    pub rotation_center: Option<(Expression, Expression)>, // Optional rotation center
}

impl Spanned for CostumeDefinition {
    fn span(&self) -> &Span {
        &self.span
    }
}
#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct SoundDefinition {
    pub span: Span,
    pub id: String,
    pub filename: String,
    pub rate: Option<Expression>, // Optional sample rate
}

impl Spanned for SoundDefinition {
    fn span(&self) -> &Span {
        &self.span
    }
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct VariableDefinition {
    pub span: Span,
    pub id: String,
    pub sprite_only: bool,
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct ListDefinition {
    pub span: Span,
    pub id: String,
    pub sprite_only: bool,
    pub items: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct Event {
    pub span: Span,
    pub id: String,
    pub args: Vec<Expression>,
    pub body: Do,
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct Do {
    pub span: Span,
    pub instructions: Vec<Instruction>,
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub enum Block {
    BlockDefinition(BlockDefinition),
    VariableDefinition(VariableDefinition),
    ListDefinition(ListDefinition),
    Event(Event),
    Do(Do),
    CostumeDefinition(CostumeDefinition),
    SoundDefinition(SoundDefinition),
}
impl From<CostumeDefinition> for Block {
    fn from(value: CostumeDefinition) -> Self {
        Self::CostumeDefinition(value)
    }
}

impl From<SoundDefinition> for Block {
    fn from(value: SoundDefinition) -> Self {
        Self::SoundDefinition(value)
    }
}
impl From<BlockDefinition> for Block {
    fn from(value: BlockDefinition) -> Self {
        Self::BlockDefinition(value)
    }
}

impl From<VariableDefinition> for Block {
    fn from(value: VariableDefinition) -> Self {
        Self::VariableDefinition(value)
    }
}

impl From<ListDefinition> for Block {
    fn from(value: ListDefinition) -> Self {
        Self::ListDefinition(value)
    }
}

impl From<Event> for Block {
    fn from(value: Event) -> Self {
        Self::Event(value)
    }
}

impl From<Do> for Block {
    fn from(value: Do) -> Self {
        Self::Do(value)
    }
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct If {
    pub span: Span,
    pub condition: Expression,
    pub then_block: Do,
    pub else_block: Option<Do>,
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct Invocation {
    pub span: Span,
    pub block_id: String,
    pub args: Vec<Expression>,
    pub body: Option<Do>,
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub enum Instruction {
    Invocation(Invocation),
    If(If),
}

impl From<Invocation> for Instruction {
    fn from(value: Invocation) -> Self {
        Self::Invocation(value)
    }
}

impl From<If> for Instruction {
    fn from(value: If) -> Self {
        Self::If(value)
    }
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct Function {
    pub span: Span,
    pub id: String,
    pub args: Vec<(String, Expression)>,
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct Literal {
    pub span: Span,
    pub value: String,
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct Variable {
    pub span: Span,
    pub id: String,
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub enum Expression {
    Variable(Variable),
    Literal(Literal),
    Function(Function),
}

impl From<Variable> for Expression {
    fn from(value: Variable) -> Self {
        Self::Variable(value)
    }
}

impl From<Literal> for Expression {
    fn from(value: Literal) -> Self {
        Self::Literal(value)
    }
}

impl From<Function> for Expression {
    fn from(value: Function) -> Self {
        Self::Function(value)
    }
}

pub trait Spanned {
    fn span(&self) -> &Span;
}

impl Spanned for Expression {
    fn span(&self) -> &Span {
        match self {
            Self::Variable(Variable { span, .. }) => span,
            Self::Literal(Literal { span, .. }) => span,
            Self::Function(Function { span, .. }) => span,
        }
    }
}

impl Spanned for Instruction {
    fn span(&self) -> &Span {
        match self {
            Self::Invocation(Invocation { span, .. }) => span,
            Self::If(If { span, .. }) => span,
        }
    }
}

impl Spanned for Block {
    fn span(&self) -> &Span {
        match self {
            Self::BlockDefinition(BlockDefinition { span, .. }) => span,
            Self::Event(Event { span, .. }) => span,
            Self::Do(Do { span, .. }) => span,
            Self::VariableDefinition(VariableDefinition { span, .. }) => span,
            Self::ListDefinition(ListDefinition { span, .. }) => span,
            Self::CostumeDefinition(CostumeDefinition { span, .. }) => span,
            Self::SoundDefinition(SoundDefinition { span, .. }) => span,
        }
    }
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct Program {
    pub blocks: Vec<Block>,
}
