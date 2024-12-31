use byteorder::ReadBytesExt;
use std::{
    collections::VecDeque,
    env,
    fs::File,
    io::{stdout, BufRead, BufReader, Cursor, Read, Seek, Write},
    path::PathBuf,
    process::exit,
};
mod rpm {
    use std::{
        ffi::{c_char, CStr, CString},
        fs::read,
        io::{BufRead, Error, ErrorKind, Read, Seek, SeekFrom},
        slice,
    };

    use byteorder::{BigEndian, ReadBytesExt};

    #[derive(Debug)]
    pub struct Lead {
        pub magic: [u8; 4],
        pub major: u8,
        pub minor: u8,
        pub package_type: u16,
        pub archnum: u16,
        pub name: String,
        pub osnum: u16,
        pub signature_type: SignatureType,
        pub reserved: [u8; 16],
    }

    #[derive(Debug)]
    pub enum SignatureType {
        None,
        Pgp262_1024,
        HeaderSig,
        Unknown(u16),
    }

    impl From<u16> for SignatureType {
        fn from(value: u16) -> Self {
            match value {
                0 => Self::None,
                1 => Self::Pgp262_1024,
                5 => Self::HeaderSig,
                _ => Self::Unknown(value),
            }
        }
    }

    #[derive(Debug, PartialEq, Eq)]
    pub enum IndexType {
        Null,
        Char,
        Int8,
        Int16,
        Int32,
        Int64,
        String,
        Bin,
        StringArray,
        I18nString,
        Unknown(u32),
    }

    impl From<u32> for IndexType {
        fn from(value: u32) -> Self {
            match value {
                0 => Self::Null,
                1 => Self::Char,
                2 => Self::Int8,
                3 => Self::Int16,
                4 => Self::Int32,
                5 => Self::Int64,
                6 => Self::String,
                7 => Self::Bin,
                8 => Self::StringArray,
                9 => Self::I18nString,
                _ => Self::Unknown(value),
            }
        }
    }

    #[derive(Debug)]
    pub enum Entry {
        Signatures(Vec<u8>),
        Immutable(Vec<u8>),
        I18nTable(Vec<String>),

        SignatureSize,
        PayloadSize,

        Sha1(String),
        Md5(Vec<u8>),
        Dsa(Vec<u8>),
        Rsa(Vec<u8>),
        Pgp(Vec<u8>),
        Gpg(Vec<u8>),

        Name(String),
        Version(String),
        Release(String),
        Summary(Vec<String>),
        Description(Vec<String>),
        PackageSize,
        Distribution(String),
        Vendor(String),
        License(String),
        Packager(String),
        Group(Vec<String>),
        Url(String),
        Os(String),
        Arch(String),
        SourceRpm(String),
        ArchiveSize,
        RpmVersion(String),
        Cookie(String),
        DistUrl(String),
        PayloadFormat(String),
        PayloadCompressor(String),
        PayloadFlags(String),

        PreInstall(String),
        PostInstall(String),
        PreUninstall(String),
        PostUninstall(String),
        PreInstallInterpreter(String),
        PostInstallInterpreter(String),
        PreUninstallInterpreter(String),
        PostUninstallInterpreter(String),

        OldFileNames(Vec<String>),
        FileSizes,
        FileModes,
        FileDevs,
        FileMTimes,
        FileMd5s(Vec<String>),
        FileLinkTos(Vec<String>),
        FileFlags,
        FileUserName(Vec<String>),
        FileGroupName(Vec<String>),
        FileDevices,
        FileInodes,
        FileLangs(Vec<String>),
        DirIndexes,
        BaseNames(Vec<String>),
        DirNames(Vec<String>),

        Unknown(u32),
    }

    impl Entry {
        fn read_bin(
            read: &mut (impl BufRead + Seek),
            index: &HeaderIndex,
        ) -> Result<Vec<u8>, std::io::Error> {
            if index.index_type != IndexType::Bin {
                eprintln!("Expected data type Bin for {index:?}, skipping");
                return Ok(Vec::new());
            }
            let mut bin = vec![0u8; index.count as usize];
            read.seek(SeekFrom::Start(index.offset as u64))?;
            read.read_exact(&mut bin)?;
            Ok(bin)
        }

        fn read_str(
            read: &mut (impl BufRead + Seek),
            index: &HeaderIndex,
        ) -> Result<String, std::io::Error> {
            if index.index_type != IndexType::String {
                eprintln!("Expected data type String for {index:?}, skipping");
                return Ok(String::new());
            }

            read.seek(SeekFrom::Start(index.offset as u64))?;

            let mut bin = Vec::new();
            let mut ch = read.read_u8()?;

            while ch != 0 {
                bin.push(ch);
                ch = read.read_u8()?;
            }

            String::from_utf8(bin).map_err(|_| ErrorKind::InvalidData.into())
        }

        fn read_str_array(
            read: &mut (impl BufRead + Seek),
            index: &HeaderIndex,
        ) -> Result<Vec<String>, std::io::Error> {
            if index.index_type != IndexType::StringArray {
                eprintln!("Expected data type String for {index:?}, skipping");
                return Ok(Vec::new());
            }

            read.seek(SeekFrom::Start(index.offset as u64))?;

            let mut arr = Vec::new();

            for _ in 0..index.count {
                let mut bin = Vec::new();
                let mut ch = read.read_u8()?;

                while ch != 0 {
                    bin.push(ch);
                    ch = read.read_u8()?;
                }

                let s = String::from_utf8(bin)
                    .map_err(|_| std::io::Error::from(ErrorKind::InvalidData))?;

                arr.push(s);
            }

            Ok(arr)
        }

        pub fn from_index(
            read: &mut (impl BufRead + Seek),
            index: &HeaderIndex,
        ) -> Result<Self, std::io::Error> {
            let entry = match index.tag {
                // Header private
                62 => Self::Signatures(Self::read_bin(read, index)?),
                63 => Self::Immutable(Self::read_bin(read, index)?),
                100 => Self::I18nTable(Self::read_str_array(read, index)?),

                // Signature
                1000 => Self::SignatureSize,
                1007 => Self::PayloadSize,

                // Signature digest
                269 => Self::Sha1(Self::read_str(read, index)?),
                1004 => Self::Md5(Self::read_bin(read, index)?),

                // Signature signing
                267 => Self::Dsa(Self::read_bin(read, index)?),
                268 => Self::Rsa(Self::read_bin(read, index)?),
                1002 => Self::Pgp(Self::read_bin(read, index)?),
                1005 => Self::Gpg(Self::read_bin(read, index)?),

                // Package information
                1000 => Self::Name(Self::read_str(read, index)?),
                1001 => Self::Version(Self::read_str(read, index)?),
                1002 => Self::Release(Self::read_str(read, index)?),
                1004 => Self::Summary(Self::read_str_array(read, index)?),
                1000 => Self::Description(Self::read_str_array(read, index)?),
                1009 => Self::PackageSize,
                1010 => Self::Distribution(Self::read_str(read, index)?),
                1011 => Self::Vendor(Self::read_str(read, index)?),
                1014 => Self::License(Self::read_str(read, index)?),
                1015 => Self::Packager(Self::read_str(read, index)?),
                1016 => Self::Group(Self::read_str_array(read, index)?),
                1020 => Self::Url(Self::read_str(read, index)?),
                1021 => Self::Os(Self::read_str(read, index)?),
                1022 => Self::Arch(Self::read_str(read, index)?),
                1044 => Self::SourceRpm(Self::read_str(read, index)?),
                1046 => Self::ArchiveSize,
                1064 => Self::RpmVersion(Self::read_str(read, index)?),
                1094 => Self::Cookie(Self::read_str(read, index)?),
                1123 => Self::DistUrl(Self::read_str(read, index)?),
                1124 => Self::PayloadFormat(Self::read_str(read, index)?),
                1125 => Self::PayloadCompressor(Self::read_str(read, index)?),
                1126 => Self::PayloadFlags(Self::read_str(read, index)?),

                // Installation
                1023 => Self::PreInstall(Self::read_str(read, index)?),
                1024 => Self::PostInstall(Self::read_str(read, index)?),
                1025 => Self::PreUninstall(Self::read_str(read, index)?),
                1026 => Self::PostUninstall(Self::read_str(read, index)?),
                1085 => Self::PreInstallInterpreter(Self::read_str(read, index)?),
                1086 => Self::PostInstallInterpreter(Self::read_str(read, index)?),
                1087 => Self::PreUninstallInterpreter(Self::read_str(read, index)?),
                1088 => Self::PostUninstallInterpreter(Self::read_str(read, index)?),

                // File information
                1027 => Self::OldFileNames(Self::read_str_array(read, index)?),
                1028 => Self::FileSizes,
                1030 => Self::FileModes,
                1033 => Self::FileDevs,
                1034 => Self::FileMTimes,
                1035 => Self::FileMd5s(Self::read_str_array(read, index)?),
                1036 => Self::FileLinkTos(Self::read_str_array(read, index)?),
                1037 => Self::FileFlags,
                1039 => Self::FileUserName(Self::read_str_array(read, index)?),
                1040 => Self::FileGroupName(Self::read_str_array(read, index)?),
                1095 => Self::FileDevices,
                1096 => Self::FileInodes,
                1097 => Self::FileLangs(Self::read_str_array(read, index)?),
                1116 => Self::DirIndexes,
                1117 => Self::BaseNames(Self::read_str_array(read, index)?),
                1118 => Self::DirNames(Self::read_str_array(read, index)?),

                _ => Self::Unknown(index.tag),
            };

            Ok(entry)
        }
    }

    impl Lead {
        pub fn read_from(reader: &mut impl Read) -> Result<Self, std::io::Error> {
            let mut magic = [0u8; 4];

            reader.read_exact(&mut magic)?;

            if magic != [0o355, 0o253, 0o356, 0o333] {
                return Err(ErrorKind::InvalidData.into());
            }

            let mut name = [0u8; 66];
            let mut reserved = [0u8; 16];

            let major = reader.read_u8()?;
            let minor = reader.read_u8()?;
            let package_type = reader.read_u16::<BigEndian>()?;
            let archnum = reader.read_u16::<BigEndian>()?;
            reader.read_exact(&mut name)?;
            let osnum = reader.read_u16::<BigEndian>()?;
            let signature_type = reader.read_u16::<BigEndian>()?.into();
            reader.read_exact(&mut reserved)?;

            Ok(Self {
                magic,
                major,
                minor,
                package_type,
                archnum,
                name: String::from_utf8_lossy(&name).to_string(),
                osnum,
                signature_type,
                reserved,
            })
        }
    }

    #[derive(Debug)]
    pub struct Header {
        pub magic: [u8; 4],
        pub reserved: [u8; 4],
        pub nindex: u32,
        pub hsize: u32,
    }

    impl Header {
        pub fn read_from(reader: &mut impl Read) -> Result<Self, std::io::Error> {
            let mut magic = [0u8; 4];

            reader.read_exact(&mut magic)?;

            if magic != [0o216, 0o255, 0o350, 0o001] {
                return Err(ErrorKind::InvalidData.into());
            }

            let mut reserved = [0u8; 4];

            reader.read_exact(&mut reserved)?;

            let nindex = reader.read_u32::<BigEndian>()?;
            let hsize = reader.read_u32::<BigEndian>()?;

            Ok(Self {
                magic,
                reserved,
                nindex,
                hsize,
            })
        }
    }

    #[derive(Debug)]
    pub struct HeaderIndex {
        pub tag: u32,
        pub index_type: IndexType,
        pub offset: u32,
        pub count: u32,
    }

    impl HeaderIndex {
        pub fn read_from(reader: &mut impl Read) -> Result<Self, std::io::Error> {
            let tag = reader.read_u32::<BigEndian>()?;
            let index_type = reader.read_u32::<BigEndian>()?.into();
            let offset = reader.read_u32::<BigEndian>()?;
            let count = reader.read_u32::<BigEndian>()?;

            Ok(Self {
                tag,
                index_type,
                offset,
                count,
            })
        }
    }
}

mod cpio {
    use std::io::{BufRead, Read};

    use byteorder::{BigEndian, ReadBytesExt};

    #[derive(Debug)]
    pub struct Header {
        magic: [u8; 6],
        ino: u64,
        mode: u64,
        uid: u64,
        gid: u64,
        nlink: u64,
        mtime: u64,
        filesize: u64,
        devmajor: u64,
        devminor: u64,
        rdevmajor: u64,
        rdevminor: u64,
        namesize: u64,
        checksum: u64,
    }

    impl Header {
        pub fn read_from(reader: &mut impl Read) -> Result<Self, std::io::Error> {
            let mut magic = [0u8; 6];

            reader.read_exact(&mut magic)?;

            Ok(Self {
                magic,
                ino: reader.read_u64::<BigEndian>()?,
                mode: reader.read_u64::<BigEndian>()?,
                uid: reader.read_u64::<BigEndian>()?,
                gid: reader.read_u64::<BigEndian>()?,
                nlink: reader.read_u64::<BigEndian>()?,
                mtime: reader.read_u64::<BigEndian>()?,
                filesize: reader.read_u64::<BigEndian>()?,
                devmajor: reader.read_u64::<BigEndian>()?,
                devminor: reader.read_u64::<BigEndian>()?,
                rdevmajor: reader.read_u64::<BigEndian>()?,
                rdevminor: reader.read_u64::<BigEndian>()?,
                namesize: reader.read_u64::<BigEndian>()?,
                checksum: reader.read_u64::<BigEndian>()?,
            })
        }
    }
}
use flate2::read::GzDecoder;
pub fn main() {
    let mut args = env::args().collect::<VecDeque<_>>();
    let wd: Option<String> = env::var("BUILD_WORKING_DIRECTORY").ok();
    let program = args.pop_front().expect("program");
    let rpm_file = args.pop_front().expect("Missing rpm file");

    let rpm_file = wd
        .map(|wd| PathBuf::from(wd).join(&rpm_file))
        .unwrap_or_else(|| rpm_file.into());

    let rpm_file = File::open(&rpm_file).expect("Error reading file");

    let mut reader = BufReader::new(rpm_file);

    let lead = rpm::Lead::read_from(&mut reader).expect("rpmlead");

    eprintln!("{lead:?}");

    match lead.signature_type {
        rpm::SignatureType::HeaderSig => read_header(&mut reader, false).expect("signature header"),
        _ => {}
    }

    read_header(&mut reader, true).expect("main header");

    let mut file = File::create("/tmp/cpio.bin").unwrap();
    std::io::copy(&mut reader, &mut file).unwrap();
    // let mut decoder = GzDecoder::new(reader);

    // dbg!(cpio::Header::read_from(&mut decoder).expect("cpio header"));
}

fn read_header(reader: &mut impl BufRead, main_header: bool) -> Result<(), std::io::Error> {
    let header = rpm::Header::read_from(reader).expect("signature");

    eprintln!("{header:?}");

    let mut header_indices = vec![0u8; header.nindex as usize * 16];
    let mut header_data = vec![0u8; header.hsize as usize];
    let header_size = header_indices.len() + header_data.len();

    reader.read_exact(&mut header_indices)?;
    reader.read_exact(&mut header_data)?;

    let mut header_indices = Cursor::new(header_indices);
    let mut header_data = Cursor::new(header_data);

    for i in 0..header.nindex {
        let index = rpm::HeaderIndex::read_from(&mut header_indices).expect("entry");
        let entry = rpm::Entry::from_index(&mut header_data, &index)?;
        eprintln!("{entry:?}");
    }

    if !main_header {
        reader.consume(8 - (header_size as usize % 8));
    }

    Ok(())
}
