import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaanap_admin_new/config/routes/routes_name.dart';
import 'package:gaanap_admin_new/res/color/colors.dart';
import 'package:gaanap_admin_new/res/images/images.dart';

class EventItem extends StatelessWidget {
  const EventItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.of(context).pushNamed(RoutesName.eventDetailScreen);
      },
      child: Card(
        color: Colors.white,
        child: Container(

          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: Row(
            children: [
              Image.asset(AppImages.eventImage,
              width: MediaQuery.of(context).size.width *.25,
              height: 100,
              fit: BoxFit.fitHeight,),
              const SizedBox(width: 10,),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hindi Film Music Fans",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  ),),
                  const SizedBox(height: 3,),
                  Text("29 Nov, 2025",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.w400
                    ),),
        
                  const SizedBox(height: 3,),
                  Row(
                    children: [
                      Icon(Icons.watch_later_outlined,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 5,),
        
                      Text("IST",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w400
                          )
                      ),
                      const SizedBox(width: 5,),
        
                      Text("09:00 AM",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                        ),),
        
                      const SizedBox(width: 5,),
        
                      Text("CST",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w400
                          )
                      ),
                      const SizedBox(width: 5,),
        
                      Text("09:30 PM",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                        ),),
                    ],
                  ),
        
        
                  const SizedBox(height: 3,),
                  Row(
                    children: [
                      Icon(Icons.list,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 5,),
        
                      Text("Questions",
                        overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w400
                          )
                       ),
                      const SizedBox(width: 5,),
        
                      Text("10",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                        ),),
                    ],
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
