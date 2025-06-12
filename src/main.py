

import csv
import subprocess
from tkinter import Tk, filedialog


class Main:
    
    __slots__ = ('_data')

    def __init__(self):
        self._data:dict = {}

    

    def __enter__(self):
        self._get_information_from_file()
        self._get_data_from_system()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        return False
    


    def _get_information_from_file(self) -> None:
        file_path:str = self._select_file()
        self._filter_information_to_get_emails(file_path)



    @staticmethod
    def _select_file() -> str:
        root:Tk = Tk()
        root.withdraw()
        return filedialog.askopenfilename()
    


    def _filter_information_to_get_emails(self, file_path:str) -> None:
        with open(file_path, 'r', encoding='utf-8') as csvfile:
            data = csv.reader(csvfile)
            next(data)
            next(data)

            for line in data:
                self._data[line[0]] = {'id': None, 'type': None}


    
    def _get_data_from_system(self) -> None:
        filter:list = "(|" + "".join(f"(extensionAttribute5={email})" for email in self._data) + ")"
        print(filter)





with Main() as filter:
    ...