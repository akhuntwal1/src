CC  = mpicc 
CXX = mpic++

YICES_PATH = $(shell cd ../../yices-1.0.28; pwd)
SMTDP_PATH = $(shell cd ../../smt_dp ; pwd)
BOOST_PATH = /usr/local/lib

AC_FLAGS = -DRSS_EXTENSION=1 -I$(BOOST_PATH)


LD_FLAGS_BOOST1 = -Wl,-rpath,$(BOOST_PATH)
LD_FLAGS_BOOST2 = -Wl,-rpath-link,$(BOOST_PATH)
LD_FLAGS_BOOST3 = -Wl,-L,$(BOOST_PATH)
LD_FLAGS_BOOST = $(LD_FLAGS_BOOST1) $(LD_FLAGS_BOOST2) $(LD_FLAGS_BOOST3) -lboost_mpi -lboost_serialization

LD_FLAGS = $(LD_FLAGS_BOOST)

CCFLAGS = -g -pthread -D__USE_XOPEN2K -fpermissive -Wunused-variable -Wno-deprecated $(AC_FLAGS)

LIB_SRC_NAME  =  inspect_util   inspect_pthread   \
                 inspect_event  object_table      \
                 inspect_clap   lin_checker       \
		 debug \

VRF_SRC_NAME  =  event_buffer                     \
                 event_relation_graph             \
                 scheduler       state            \
                 lockset         state_stack      \
                 scheduler_object_table           \
                 inspect_main                     \
                 transition_set                   \
                 thread_info                      \
                 clock_vector                     \
                 program_state                    \
                 scheduler_setting                \
                 next_state                       \
                 inspect_trace                    \


ALL_SRC_NAME  = $(LIB_SRC_NAME) $(VRF_SRC_NAME)


INSPECTOR = inspect

LIBDIR =  ../lib
INSPECTOR_LIB = $(LIBDIR)/lib$(INSPECTOR).a
INSPECTOR_DLL = $(LIBDIR)/lib$(INSPECTOR).so


LIB_OBJS = $(foreach file, $(LIB_SRC_NAME), $(file).o)
DLL_OBJS = $(foreach file, $(LIB_SRC_NAME), $(file).os)
VRF_OBJS = $(foreach file, $(VRF_SRC_NAME), $(file).o)

ALL_SRC = $(foreach src_name, $(ALL_SRC_NAME), $(src_name).cc )

all:   $(INSPECTOR) $(INSPECTOR_LIB) $(INSPECTOR_DLL)


$(INSPECTOR): $(LIB_OBJS) $(VRF_OBJS)
	$(CXX) $(CCFLAGS) -o $(INSPECTOR) $(VRF_OBJS) $(LIB_OBJS) $(LD_FLAGS) -lpthread -lrt 

$(INSPECTOR_LIB): $(LIB_OBJS)
	ar rcs $@ $(LIB_OBJS)
	ranlib $@

$(INSPECTOR_DLL): $(DLL_OBJS)
	$(CC) -shared -o $@  $(DLL_OBJS)

clean:  
	@echo "Cleaning object files ...."
	@rm -f *.o *.os *.d
	@rm -f $(INSPECTOR_LIB) 
	@rm -f $(INSPECTOR_DLL) 
	@rm -f $(INSPECTOR)


-include $(OBJS:.o=.d)

%.o : %.cc naling.def
	$(CXX) $(CCFLAGS) -c  $^  -o $@
	$(CXX) $(CCFLAGS) -MM $^ > $*.d
	@cp -f $*.d $*.d.tmp
	@sed -e 's/.*://' -e 's/\\$$//'  < $*.d.tmp | fmt -1 | \
	 sed -e 's/^ *//' -e 's/$$/:/'  >> $*.d
	@rm -f $*.d.tmp

%.os : %.cc naling.def
	$(CXX) $(CCFLAGS) -fPIC -c $^ -o $@
	$(CXX) $(CCFLAGS) -MM $^ > $*.d
	@cp -f $*.d $*.d.tmp
	@sed -e 's/.*://' -e 's/\\$$//'  < $*.d.tmp | fmt -1 | \
	 sed -e 's/^ *//' -e 's/$$/:/'  >> $*.d
	@rm -f $*.d.tmp

