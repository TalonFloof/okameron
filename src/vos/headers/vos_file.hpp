#pragma once

#include <string>
using std::string;

#include <fstream>
#include <sstream>

class VosFile {
public:
    VosFile(string filename_) {
        filename = filename_;
        try {
            std::fstream inFile;
            inFile.open(filename_);
            if (!inFile.is_open()) {
		        throw "Unable to open '"+filename_+"'";
            } else {
                std::stringstream strStream;
                strStream << inFile.rdbuf();
                data = strStream.str();
                inFile.close();
	        }
        } catch (string err) {
            throw err;
        }
    }

    string getFileName() {return filename;}
    string getData() {return data;}
private:
    string filename;
    string data;
};