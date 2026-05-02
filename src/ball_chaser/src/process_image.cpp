#include "ros/ros.h"
#include "ball_chaser/DriveToTarget.h"
#include <sensor_msgs/Image.h>

// Define a global client that can request services
ros::ServiceClient client;

// This function calls the command_robot service to drive the robot in the specified direction
void drive_robot(float lin_x, float ang_z)
{
    // ROS_INFO_STREAM("Driving robot: linear_x=" << lin_x << ", angular_z=" << ang_z);

    ball_chaser::DriveToTarget srv;
    srv.request.linear_x = lin_x;
    srv.request.angular_z = ang_z;

    // Call the service
    if (!client.call(srv)) {
        ROS_ERROR("Failed to call service ball_chaser/command_robot");
    }
}

// This callback function continuously executes and reads the image data
void process_image_callback(const sensor_msgs::Image img)
{
    int white_pixel = 255;
    
    long column_sum = 0;     
    int white_pixel_count = 0; 

    // Loop through each pixel in the image (RGB = 3 bytes per pixel)
    for (int i = 0; i < img.height * img.step; i += 3) {
        
        // Strict white check (255, 255, 255)
        if (img.data[i] == white_pixel && img.data[i+1] == white_pixel && img.data[i+2] == white_pixel) {
            
            int col = (i % img.step) / 3;
            column_sum += col;
            white_pixel_count++;
        }
    }

    // Only move if we see a significant chunk of the ball (more than 10 pixels)
    if (white_pixel_count > 10) {
        
        int mean_col = column_sum / white_pixel_count;
        int center = img.width / 2;
        int error = center - mean_col;

        // FIXED: Kp is now POSITIVE 
        // Ball on Left -> mean_col is small -> error is positive -> Turn Left (Positive Z)
        float Kp = 0.005; 
        float angular_z = Kp * error;

        // Move forward, but slow down if we are turning sharp
        float linear_x = 0.5 * (1.0 - std::abs(angular_z)); 
        if (linear_x < 0.0) linear_x = 0.0; // Prevent backward motion

        drive_robot(linear_x, angular_z);
    } 
    else {
        // Stop if no ball is visible
        drive_robot(0.0, 0.0);
    }
}

int main(int argc, char** argv)
{
    ros::init(argc, argv, "process_image");
    ros::NodeHandle n;

    client = n.serviceClient<ball_chaser::DriveToTarget>("/ball_chaser/command_robot");
    ros::Subscriber sub1 = n.subscribe("/camera/rgb/image_raw", 10, process_image_callback);

    ros::spin();

    return 0;
}
