set(Z3_DIR $ENV{Z3_DIR})
get_filename_component(Z3_DIR ${Z3_DIR} ABSOLUTE)
set(Z3_CXX_INCLUDE_DIRS ${Z3_DIR}/include)
set(Z3_LIBRARIES ${Z3_DIR}/bin/libz3.so)
message(STATUS "Z3_DIR: ${Z3_DIR}")


include_directories(${Z3_CXX_INCLUDE_DIRS})

add_executable(dse
  src/DSE.cpp
  src/Strategy.cpp
  )
  
include_directories(include)

add_library(InstrumentPass MODULE
  src/Instrument.cpp
  )
  
llvm_map_components_to_libnames(llvm_libs support core irreader)
  

target_link_libraries(dse ${llvm_libs} ${Z3_LIBRARIES})

add_library(runtime MODULE
  src/SymbolicInterpreter.cpp
  src/Runtime.cpp
  )

target_link_libraries(runtime ${llvm_libs} ${Z3_LIBRARIES})


  
target_compile_features(InstrumentPass PRIVATE cxx_range_for cxx_auto_type)

set_target_properties(InstrumentPass PROPERTIES
        COMPILE_FLAGS "-g"
        )

target_compile_features(dse PRIVATE cxx_range_for cxx_auto_type)

set_target_properties(dse PROPERTIES
        COMPILE_FLAGS "-g"
        )
if(APPLE)
    set_target_properties(InstrumentPass PROPERTIES
            LINK_FLAGS "-undefined dynamic_lookup"
            )
    set_target_properties(dse PROPERTIES
            LINK_FLAGS "-undefined dynamic_lookup"
            )
endif(APPLE)
