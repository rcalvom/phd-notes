option(USE_REFERENCE "Build with reference solution" OFF)

include_directories(include)
link_directories(${LLVM_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/reference)

if (USE_REFERENCE)
  message(STATUS "Use reference solution")
  add_library(DataflowPass MODULE
    src/DataflowAnalysis.cpp
    src/DivZeroAnalysis.cpp
    src/Domain.cpp
  )
  
  target_link_libraries(DataflowPass RefDomain)
  
else (USE_REFERENCE)
  add_library(DataflowPass MODULE
  src/DataflowAnalysis.cpp
  src/DivZeroAnalysis.cpp
  src/Domain.cpp
  )
endif (USE_REFERENCE)

target_compile_features(DataflowPass PRIVATE cxx_range_for cxx_auto_type)

set_target_properties(DataflowPass PROPERTIES
        COMPILE_FLAGS "-g"
        )

if(APPLE)
    set_target_properties(DataflowPass PROPERTIES
            LINK_FLAGS "-undefined dynamic_lookup"
            )
endif(APPLE)
