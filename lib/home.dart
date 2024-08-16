import 'dart:math';

import 'package:flutter/material.dart';
import 'package:note_wave/pages/notes/notes.dart';
import 'package:note_wave/service/auth_service.dart';
import '/pages/habit/habit.dart';
import '/pages/todo/todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int showDrawer = 0;

  final ValueNotifier<Homepages>  _currentPage = ValueNotifier(Homepages.notes);
  final AuthService _service = AuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: const AssetImage('assets/road.jpg',),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
          ),
        ),
        child: Stack(
          children: [
           SafeArea(
               child:Material(
                 color: Colors.transparent,
                 child: Container(
                   width: 200,
                   padding:const EdgeInsets.all(10.0),
                   margin: const EdgeInsets.only(top: 70.0),
                   child: Column(
                     children: [
                       Expanded(
                         child: ListView(
                         children: [
                           ListTile(
                             onTap: (){
                               _currentPage.value = Homepages.notes;
                               closeDrawer();
                             },
                             leading: const Icon(Icons.notes_outlined,size:25.0,color: Colors.white,),
                             title: const Text('Notes',style: TextStyle(
                               fontSize: 18.0,
                               color: Colors.white,
                             ),),
                           ),
                           ListTile(
                             onTap: (){
                               _currentPage.value = Homepages.tasks;
                               closeDrawer();
                             },
                             leading: const Icon(Icons.task_outlined,size:25.0,color: Colors.white,),
                             title: const Text('Tasks',style: TextStyle(
                               fontSize: 18.0,
                               color: Colors.white,
                             ),),
                           ),
                           ListTile(
                             onTap: (){
                               _currentPage.value = Homepages.habits;
                               closeDrawer();
                             },
                             leading: const Icon(Icons.run_circle_outlined,size:25.0,color: Colors.white,),
                             title: const Text('Habit',style: TextStyle(
                               fontSize: 18.0,
                               color: Colors.white,
                             ),),
                           ),
                           ListTile(
                             onTap: (){
                               closeDrawer();
                             },
                             leading: const Icon(Icons.close_outlined,size:25.0,color: Colors.white,),
                             title: const Text('close',style: TextStyle(
                               fontSize: 18.0,
                               color: Colors.white,
                             ),),
                           ),
                           ListTile(
                             onTap: (){
                               _service.signOut();
                             },
                             leading: const Icon(Icons.logout_outlined,size:25.0,color: Colors.white,),
                             title: const Text('Log out',style: TextStyle(
                               fontSize: 18.0,
                               color: Colors.white,
                             ),),
                           ),
                         ],
                       ),),
                     ],
                   ),
                 ),
               ),
           ),
            TweenAnimationBuilder(
                tween: Tween<double>(
                  begin: 0,
                  end: showDrawer == 1 ? 1:0,
                ),
                duration: const Duration(microseconds: 300),
                builder: (_,double v,__){
                  return Transform(
                    alignment: Alignment.center,
                      transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..setEntry(0, 3, 200*v)
                          ..rotateY((pi/6)*v),
                    child: ClipRRect(
                      borderRadius: showDrawer==1?BorderRadius.circular(10.0):BorderRadius.circular(10.0),
                      child:  ValueListenableBuilder(
                          valueListenable: _currentPage,
                        builder: (context,page,child) {
                          return Scaffold(
                            appBar: AppBar(
                              backgroundColor: Colors.white,
                              title:  Text(page.title),
                              centerTitle: true,
                              leading: InkWell(
                                onTap: (){
                                  if(showDrawer == 0){
                                    setState(() {
                                      showDrawer = 1;
                                    });
                                  }else{
                                    setState(() {
                                      showDrawer = 0;
                                    });
                                  }
                                },
                                child: const Icon(Icons.menu,),
                              ),
                            ),
                            body:  SafeArea(top:true,bottom:false,child:
                            switch(page){
                              Homepages.notes => const NotesPage(),
                            Homepages.tasks => const TodoPage(),
                            Homepages.habits=> const HabitPage(),

                            }),

                          );
                        }
                      ),
                    ),
                  );
                },
            ),
            // this allows the user to slide from the edge of the screen horizontally to open the nav drawer.
            // GestureDetector(
            //   onHorizontalDragUpdate: (value){
            //     if(value.delta.dx>0){
            //       setState(() {
            //         showDrawer=1;
            //       });
            //     }else{
            //       toggleDrawer();
            //     }
            //   },
            // )
          ],
        ),
    );
  }

  void toggleDrawer(){
    if(isDrawerOpen()){
      closeDrawer();
    }else{
      openDrawer();
    }
  }

  void closeDrawer(){
    setState(() {
      showDrawer=0;
    });
  }
  void openDrawer(){
    setState(() {
      showDrawer=1;
    });
  }

  bool isDrawerOpen(){
    return showDrawer == 1;
  }
}
enum Homepages{
  notes("Notes"),
  tasks('Task List'),
  habits('Habit Tracker');
  final String title;
  const Homepages(this.title);
}
