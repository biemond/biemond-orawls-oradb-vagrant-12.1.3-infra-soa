select 
    t.tablespace_name,
    logging,
    extent_management,
    segment_space_management,
    bigfile,
    file_name,
    contents,
    to_char(increment_by, '9999999999999999999') "INCREMENT_BY",
    to_char(block_size, '9999999999999999999') "BLOCK_SIZE",
    autoextensible,
    to_char(bytes, '9999999999999999999') "BYTES",
    to_char(maxbytes, '9999999999999999999') "MAX_SIZE"
from 
    dba_tablespaces t, 
    dba_data_files f 
where
    t.tablespace_name = f.tablespace_name