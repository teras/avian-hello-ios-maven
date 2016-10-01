# avian-hello-ios-maven
Mavenize port of Avian's "hello-ios" project

Avian and the original "hello-ios" project can be found at https://github.com/ReadyTalk/avian and
https://github.com/ReadyTalk/hello-ios first.

To compile and run this project, please follow the following steps on a macOS machine.
*  Run script `./scripts/create-artifacts.sh` . This script will fetch Avian, compile it, and create the maven artifact with
the required files. This procedure needs to be done only once (or when Avian gets updated). Note that when the
procedure will finish sucessfully, it is possible to delete this file, as well as folders `avian` and `build`.
*  Open XCode file `TestProject.xcodeproj` and run project. Note that, under the hood, the project will launch mvn if
required, convert classfiles to binary objects and link them together. 
*  There is no step three. Enjoy Java on the iPhone.

## Implementation notes
*  Only compiled version of Avian is used. Interprented version is sometimes even 10 times slower, than compiled version.
Since JIT is not allowed in the Store, compiled code is the only practical solution, even if compiled code results to
a bigger file.
*  Avian classpath library is used. If you want to use any other library, it ispossible to edit the maven script, remove
the `avian-ios-maven-lib` plugin with classifier `classpath` and replace it with one of your own.
*  Proguard is not embedded in the pipeline. Again, the usual maven pipeline could be used.
*  The compiled sources are not bootstrapped with the Avian classpath.
