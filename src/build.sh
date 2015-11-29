cd ..
direct=`pwd`
output_dir=$direct/../out
cd src

if [ $2 = "clean" ];
then
	echo --------------------------------
	echo -  Performing extended cleanup -
	echo --------------------------------


	cd $direct/src/sw/elf  
	make clean PROJECT_PATH=$direct 
	cd  $direct/src/orpsocv2/boards/xilinx/atlys/backend/par/run
	make distclean

	mkdir -p $output_dir
else
	echo --------------------------------
	echo -  Performing standard cleanup -
	echo --------------------------------
	#rm -r -f  $output_dir
	rm -r -f  $output_dir/*

	mkdir -p $output_dir

fi








if [ $1 = "elf" ]; 
then
	echo ------------------------
	echo - Compiling bare metal -
	echo ------------------------

	cd $direct/src/sw/elf
	make clean all

	bin_file=test.bin

	cp $direct/src/Libs/or1ksim.cfg $output_dir
fi


if [ $1 = "elf" ];
then
echo ------------------------------------------
echo Creating orpsoc.mcs with file $bin_file 
echo ------------------------------------------
cd $direct/src/orpsocv2/boards/xilinx/atlys/backend/par/run
rm -f orpsoc.mcs
echo "Making with file $output_dir/$bin_file"
make orpsoc.mcs BOOTLOADER_BIN=$output_dir/$bin_file
cp orpsoc.mcs $output_dir

else
echo --------------------------------
echo -  No parameters specified     -
echo --------------------------------


fi


echo ---------------------
echo -        Done       -
echo ---------------------

