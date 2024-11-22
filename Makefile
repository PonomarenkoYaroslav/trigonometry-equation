CXX	=	g++
CXXFLAGS	=	-std=c++11	-Wall	-g
TARGET	=	my_program

SOURCES	=	$(wildcard	*.cpp)

OBJECTS	=	$(SOURCES:.cpp=.o)

all:	$(TARGET)

$(TARGET):	$(OBJECTS)
	$(CXX)	$(CXXFLAGS)	-o	$(TARGET)	$(OBJECTS)

%.o:	%.cpp	
	$(CXX)	$(CXXFLAGS)	-c	$<	-o	$@

clean:
	rm	-f	$(OBJECTS)	$(TARGET)
