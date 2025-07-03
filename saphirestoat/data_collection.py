"""This script downloads and processes the data for chapter 5
"""
from huggingface_hub import snapshot_download, hf_hub_download
import polars as pl 
import polars.selectors as cs
import numpy as np
import os 
import warnings 
class Data_Collection:
    """Executes Data Collection from Huggingface
    Contains methods for data collection 
    Attributes:
        output_dir: Path to outputted data 
        year: Year of interst
        month: month  of interest
    Methods:
        collect_data: downloads Reddit Pushift Dumps from huggingface
        create_links: creates links for specific dump files returns a polars df 
        _make_dirs: makes required directories 
    """
    def __init__(
        self
        , output_dir: str="./data"
        , years: list[int] = [2023]
        , months: list[int] = [11]
        , dump_type: str = 'comments'
    ):
        self.output_dir = output_dir
        
        self.years = years
        
        self.months = months 

        self.dump_type = dump_type
    
    def create_links(self,
                     years: list[int] = None,
                     months: list[int] = None,
                     dump_type: str = 'comments'):
        years = years if years is not None else self.years
        
        months = months if months is not None else self.months
        
        combos = np.array([[x,y] for x in years for y in months])
        df = pl.DataFrame(combos, schema = ['years', 'months']).with_columns(
            pl.col('years').cast(pl.String).alias('years'),
            pl.col('months').cast(pl.String).alias('months')
        ).with_columns(
            months = pl.when(pl.col('months').str.len_chars() < 2).then('0' + pl.col('months')).otherwise(pl.col('months'))
        )   
        if dump_type == "submission": 
            links_df = df.with_columns(
                pl.concat_str(
                    [
                        pl.lit("RS_"),
                        pl.col('years'),
                        pl.lit("-"),
                        pl.col('months'),
                        pl.lit(".zst")
                    ]
                ).alias('links')
            )
        if dump_type == "both":
           links_df = df.with_columns(
            pl.concat_str(
                [
                    pl.lit("RC_"),
                    pl.col('years'),
                    pl.lit("-"),
                    pl.col('months'),
                    pl.lit(".zst")
                ]
            ).alias('commment_links'),
            pl.concat_str(
                [
                    pl.lit("RS_"),
                    pl.col('years'),
                    pl.lit("-"),
                    pl.col('months'),
                    pl.lit(".zst")
                ]
            ).alias('submission_links')
           )
        else:
            links_df = df.with_columns(
                pl.concat_str(
                    [
                        pl.lit("RC_"),
                        pl.col('years'),
                        pl.lit("-"),
                        pl.col('months'),
                        pl.lit(".zst")
                    ]
                ).alias('links')
            )
        return links_df

    def collect_data(
        self,
        years: list[int] = None,
        months: list[int] = None,
        output_dir = None,
        dump_type: str = 'comments'
    ):

        """This is the main function to collect the data. 
        years: A list of integers. Note the dumpfiles only go back to 2005
        months: a list of months that you want to query"""


        files = self.create_links(years = years, months = months, dump_type = dump_type)
        output_dir = output_dir if output_dir is not None else self.output_dir

        os.makedirs(output_dir, exist_ok= True)

        if dump_type == 'both':

            warnings.warn('This is a massive amount of data! Be prepared for this to take a long time!', UserWarning)

            

            comments_links = files['comments_links']
            submission_links = files['submission_links']
            for i in comments_links:

                try:
                    print(f"Downloading:{i}")
                    hf_hub_download(repo_id='peternasser99/reddit', subfolder='comments' ,filename = i, repo_type='dataset', local_dir=output_dir)
                except:
                    print(f'{i} not found')
            
            for i in submission_links:
                try:
                    print(f"Downloading:{i}")
                    hf_hub_download(repo_id='peternasser99/reddit', subfolder='submissions' ,filename = i, repo_type='dataset', local_dir=output_dir)
                except:
                    print(f'{i} not found')
        if dump_type == 'submissions':
            submission_links = files['links']
            for i in submission_links:

                try:

                    print(f"Downloading:{i}")
                    hf_hub_download(repo_id='peternasser99/reddit', subfolder='submissions' ,filename = i, repo_type='dataset', local_dir=output_dir)
                except:
                    
                    print(f'{i} not found')




        else:
            files_list = files['links']
            for i in files_list:
                try:

                    print(f"Downloading:{i}")
                    hf_hub_download(repo_id='peternasser99/reddit', subfolder='comments', filename = i, repo_type='dataset', local_dir=output_dir)
                except:

                    print(f'{i} not found')
        
        
        
    


