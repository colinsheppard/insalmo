ifeq ($(SWARMHOME),)
SWARMHOME=/usr
endif

CFLAGS="-c -g -O -fgnu-runtime -fno-strict-aliasing -Wall -Wno-import -Wno-protocol -Wno-long-long  -D_GNU_SOURCE" 
#EXTRACPPFLAGS+=-pg

APPLICATION=insalmo
OBJECTS=Trout.o \
	HabitatSpace.o \
	Redd.o \
	TroutModelSwarm.o \
	TroutObserverSwarm.o \
        FishParams.o \
	SearchElement.o \
	ScenarioIterator.o \
	ExperSwarm.o \
	main.o \
\
        TimeManager.o \
\
        ExperBatchSwarm.o \
        TroutBatchSwarm.o \
\
        FallChinook.o \
\
        HabitatManager.o \
        HabitatSetup.o \
\
	SurvProb.o \
	SingleFuncProb.o \
	LimitingFunctionProb.o \
\
	SurvMGR.o \
	Func.o \
	LogisticFunc.o \
	ConstantFunc.o \
	BooleanSwitchFunc.o \
	ObjectValueFunc.o \
\
	ReddScour.o \
	ReddScourFunc.o \
\
	ReddSuperimp.o \
	ReddSuperimpFunc.o \
\
	EcoAverager.o \
	BreakoutAverager.o \
	BreakoutMessageProbe.o \
	BreakoutVarProbe.o \
	BreakoutReporter.o \
\
	TroutMortalityCount.o \
\
	InterpolationTable.o \
	TimeSeriesInputManager.o \
\
	YearShuffler.o \
	SolarManager.o \
\
	PolyInputData.o \
	PolyCell.o \
	PolyPoint.o \
	FishCell.o


OTHERCLEAN= instream-2d.exe.core instream-2d.exe unhappiness.output

include $(SWARMHOME)/etc/swarm/Makefile.appl

main.o: main.m Trout.h HabitatSpace.h TroutObserverSwarm.h 
Trout.o: Trout.m Trout.h globals.h DEBUGFLAGS.h
Redd.o: Redd.[hm] HabitatSpace.h globals.h DEBUGFLAGS.h
SurvivalProb.o: SurvivalProb.[hm] globals.h DEBUGFLAGS.h
HabitatSpace.o: HabitatSpace.[hm] globals.h DEBUGFLAGS.h
FishParams.o: FishParams.[hm] DEBUGFLAGS.h
TroutModelSwarm.o: TroutModelSwarm.[hm] globals.h FallChinook.h \
	HabitatSpace.h FishParams.h DEBUGFLAGS.h
TroutObserverSwarm.o: TroutObserverSwarm.[hm] TroutModelSwarm.h  globals.h
SearchElement.o: SearchElement.[hm]
ScenarioIterator.o: ScenarioIterator.[hm] SearchElement.h
ExperSwarm.o: ExperSwarm.[hm] SearchElement.h ScenarioIterator.h globals.h
#
TimeManager.o : TimeManager.[hm]
#
ExperBatchSwarm.o : ExperBatchSwarm.[hm]
TroutBatchSwarm.o : TroutBatchSwarm.[hm]
#
FallChinook.o : FallChinook.[hm] DEBUGFLAGS.h
#
HabitatManager.o : HabitatManager.[hm]
HabitatSetup.o : HabitatSetup.[hm]
#
#TroutOutputLive.o : TroutOutputLive.[hm]
#TroutOutputDead.o : TroutOutputDead.[hm]
#
SurvProb.o : SurvProb.[hm]
SingleFuncProb.o : SingleFuncProb.[hm] globals.h
LimitingFunctionProb.o : LimitingFunctionProb.[hm] globals.h
SurvMGR.o : SurvMGR.[hm]
#
ReddScour.o : ReddScour.[hm] SurvProb.h
ReddScourFunc.o : ReddScourFunc.[hm] Func.h
#
ReddSuperimp.o : ReddSuperimp.[hm] SurvProb.h
ReddSuperimpFunc.o : ReddSuperimpFunc.[hm] Func.h
#
Func.o : Func.[hm] globals.h
LogisticFunc.o : LogisticFunc.[hm]
ConstantFunc.o : ConstantFunc.[hm]
BooleanSwitchFunc.o : BooleanSwitchFunc.[hm]
ObjectValueFunc.o : ObjectValueFunc.[hm]
#
BreakoutReporter.o : BreakoutReporter.[hm]
EcoAverager.o : EcoAverager.[hm]
BreakoutAverager.o : BreakoutAverager.[hm]
BreakoutMessageProbe.o : BreakoutMessageProbe.[hm]
BreakoutVarProbe.o : BreakoutVarProbe.[hm]
#
TroutMortalityCount.o : TroutMortalityCount.[hm]
#
InterpolationTable.o : InterpolationTable.[hm]
TimeSeriesInputManager.o : TimeSeriesInputManager.[hm]
#
YearShuffler.o : YearShuffler.[hm]
#
SolarManager.o : SolarManager.[hm]
#
PolyInputData.o : PolyInputData.[hm]
PolyCell.o : PolyCell.[hm]
PolyPoint.o : PolyCell.[hm]
FishCell.o : FishCell.[hm]
