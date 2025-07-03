import zstandard as zstd
import io
import json
import re
import csv
import polars as pl
import polars.selectors as cs
import os 

class Process_Comments:
    """Executes Data Cleaning functions for reddit pushift dumps
    contains methods for data clearning
    Attributes:
        keywords: a list of keywords to search 
        input_file: input_file a zst file to be converted 
        output_csv: output_file a lazyframe to write 
        file_schema: an optional polars schema to pass to align schema
    Methods:
        convert_zst_to_csv: converts zst files to csv
        process_files: processes_csv files for use returns a polars lazy frame to defer computation 
        sample_comments: takes a random sample of a corpus
        align_schema: aligns lazy frame schemas
        _is_valid_zst_file: checks for valid zst magic numbers

    """
    def __init__(
        self
        , keywords: list[str] = ['aitah']
        , input_file: list[str] = ['data/comments/RC_2023-11.zst']
        , output_csv: list[str] = ['data/comments/RC_2023-11.csv']
        , file_schema: dict = None
    ):
        self.keywords = keywords
        self.input_file = input_file
        self.output_csv = output_csv
        if file_schema is None:
            self.file_schema = {
                "created_utc": pl.Int64,
                "score": pl.Int64,
                "subreddit": pl.String,
                "controversiality": pl.Int64,
                "body": pl.String,
                "edited": pl.String,
                "distinguished": pl.String,
                "parent_id": pl.String,
                "id": pl.String,
                "subreddit_id": pl.String,

            }
        else: 
            self.file_schema = file_schema


    def _is_valid_zst_file(self, input_file):
        """Check if a file is a valid zstandard file based on magic numbers"""
        try:
            with open(input_file, 'rb') as f:
                magic = f.read(4)
                return magic == b'\x28\xb5\x2f\xfd'
        except Exception:
            return False
    def convert_zst_to_csv(self, input_file: str = None, output_csv: str = None):
        """Convert a single zst file to csv"""
        input_file = input_file if input_file is not None else self.input_file[0]
        output_csv = output_csv if output_csv is not None else self.output_csv[0]
        
        if not self._is_valid_zst_file(input_file):
            raise ValueError(f"File {input_file} is not a valid zstandard (.zst) file")
        
        print(f"Converting {input_file}")
        
        with open(input_file, 'rb') as fh, open(output_csv, 'w', newline='', encoding='utf-8') as csvfile:
            dctx = zstd.ZstdDecompressor(max_window_size=2147483648)
            stream_reader = dctx.stream_reader(fh)
            text_stream = io.TextIOWrapper(stream_reader, encoding='utf-8')
            
            csv_writer = csv.writer(csvfile)
            
            # Initialize header variable outside the loop
            header = None
            
            # Iterate over each JSON object to determine headers dynamically
            for line in text_stream:
                try:
                    obj = json.loads(line)
                    
                    # Extract keys if not already done
                    if header is None:
                        header = list(obj.keys())
                        csv_writer.writerow(header)
                    
                    # Write values for each JSON object, handling missing keys gracefully
                    csv_writer.writerow([obj.get(key, '') for key in header])
                except json.JSONDecodeError:
                    # Skip malformed JSON lines
                    continue
    
    def align_schema(self, file_schema:dict = None, input_file: list[str] = None):
        """helper for process_file function 
           file_schema: a polars schema to pass to polars.cast mehtod. This will also select those columns
           input_file: the name of the csv to align"""
        input_file = input_file if input_file is not None else self.output_csv
        file_schema = file_schema if file_schema is not None else self.file_schema

        lf = pl.scan_csv(input_file, infer_schema_length=1000)
        lf = lf.cast(file_schema, strict = False)
        
        return lf.select(list(file_schema.keys()))
    
    def clean_file(self, df: pl.LazyFrame = None, keywords: list[str] = None):
        """helper for process_file function
           df: A polars lazy frame from the results of align schema
           keywords: a list of keywords you want to query in the dataframe. Note this will filter based on keywords too"""
        

        if df is None:
            raise ValueError("Please provide a data frame to clean ")

        keywords = keywords if keywords is not None else self.keywords

        keywords_list = pl.DataFrame(keywords).rename({'column_0':'words'}).with_columns(
            pl.col('words').str.to_lowercase()
        ).get_column('words').str.concat(delimiter='|').item()

        cleaned = df.with_columns(
        pl.from_epoch('created_utc', time_unit='s').alias('created_utc')
       ).with_columns(
        pl.col('created_utc').dt.year().alias('year'),
        pl.col('created_utc').dt.month().alias('month'),
        pl.col('created_utc').dt.day().alias('day'),
        pl.col('body').str.to_lowercase().alias('body')
       ).with_columns(
        pl.col('body').str.contains(keywords_list).alias('contained_word')).filter(pl.col('contained_word') == True)
        return cleaned
    def sample_frame(self, df: pl.LazyFrame, n: int = 100000, seed: int = 1994, grouping: list[str]= ['day'], text_col: str = 'body'):
        return df.filter(
            pl.int_range(pl.len()).shuffle().over(grouping) < n
        ).unique(subset = text_col) 
    
    def process_file(self,
                    input_data: list[str] = None,
                    keywords:list[str] = None,
                    file_schema: dict = None,
                    sample: bool = False,
                    sample_seed: int = 1994,
                    sample_grouping: list[str] = ['day'],
                    sample_text_col: str = 'body',
                    sample_n: int = 100000):

        """This is the main data cleaning method
        input_file: A csv file that results from the convert_zst_to_csv
        keywords: a list of keywords you are interested in 
        file_schema: A polars schema that 

        """

        file_schema = file_schema if file_schema is not None else self.file_schema
        input_file = input_data if input_data is not None else self.output_csv

        if len(input_file) > 1:

            lazy_frames = [self.align_schema(input_file = f, file_schema = file_schema) for f in input_file]
            cleaned_lazy_frame = [self.clean_file(frames, keywords = keywords) for frames in lazy_frames]
            processed_data = pl.concat(cleaned_lazy_frame, how = 'diagonal')
        else:
            lazy_frame = self.align_schema(input_file = input_file[0], file_schema = file_schema)
            processed_data = self.clean_file(lazy_frame, keywords = keywords)

        if sample is True:

            processed_data = self.sample_frame(
                processed_data,
                n = sample_n,
                seed = sample_seed,
                grouping = sample_grouping,
                text_col= sample_text_col
            )
        return processed_data
        
        









