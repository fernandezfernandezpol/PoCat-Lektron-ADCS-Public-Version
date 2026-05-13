function PlotSatAttitude(xPlot,lat,long)
%   
%   Animation of the attitude of the satellite
%   ------
%   Inputs
%   ------
%
%     xPlot     [x;power;d.tRWA ;angleError3(k+1);bField(:,k);hRWA]
%     lat       Latitude of the GS 
%     long      Longitude of the GS


figure
     numFaces = 600;
     [x,y,z] = sphere(numFaces);

     
    A=im2double(imread('earth.jpg'));
    I=imrotate(A,180);
    h=warp(x,y,z,I);
    light('Position',[1 0 0.3]);  
    h.AmbientStrength = 0.4;
    h.DiffuseStrength = 1;
    h.SpecularStrength = 0.4;
    h.SpecularExponent =1;
   
   
    axis off
    axis equal
   hold on 
     
GsOn=0;

if nargin ==3 
    
    p=plot3(cosd(lat)*cosd(long), cosd(lat)*sind(long), sind(lat),'ro');
    GsOn=1;
end



    %filename = 'LVLHpoint.gif';
    Sample=20;
    t=0;
for i=1:length(xPlot)/Sample
  
    
     hold on
    
     k=i*Sample;
     m = Unit( Q2Mat(xPlot(7:10,k)) );
     
    q1=quiver3(xPlot(1,k)/6387,xPlot(2,k)/6387,xPlot(3,k)/6387,m(1,1)/5,m(1,2)/5,m(1,3)/5,'b');
    q2=quiver3(xPlot(1,k)/6387,xPlot(2,k)/6387,xPlot(3,k)/6387,m(2,1)/5,m(2,2)/5,m(2,3)/5,'g');
    q3=quiver3(xPlot(1,k)/6387,xPlot(2,k)/6387,xPlot(3,k)/6387,m(3,1)/5,m(3,2)/5,m(3,3)/5,'r');
     q1.LineWidth=2;
     q2.LineWidth=2;
     q3.LineWidth=2;
    
     drawnow;
%     loops=65535;delay=0.1;
%     frame = getframe(1);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%       if i == 1;
%           imwrite(imind,cm,filename,'gif', 'Loopcount',loops,'DelayTime',delay);
%       else
%           imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',delay);
%       end
     
    delete(q1);
    delete(q2);
    delete(q3);  
    
    if t==20
    rotate(h,[0 0 1],0.0042*Sample*t)
    if GsOn==1
    rotate(p,[0 0 1],0.0042*Sample*t)
    end
    t=0;
    end
    
    t=t+1;
end
 

