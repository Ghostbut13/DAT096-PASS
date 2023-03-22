clc, clear all, close all
microphone(0,-1.5,0);
microphone(0,-0.5,0);
microphone(0,0.5,0);
microphone(0,1.5,0);
x= 2.5;
y = 0.5;
stickfig(x,y,0);
waver([x-0.1,0], [y,-1.5], [1.5,1]);
waver([x-0.1,0], [y,-0.5], [1.5,1]);
waver([x-0.1,0], [y,0.5], [1.5,1]);
waver([x-0.1,0], [y,1.5], [1.5,1]);
%patch([3,3,-1,-1], [2,-2,-2,2], [0,0,0,0], [1,1,1]);
n=1;
[X,Y]=meshgrid([0,n:n:4,0], [n:n:4,0,0]);
Z= 0.*X + 0.*Y;
mesh(X-1,Y-2,Z)
axis equal
axis off
%grid on

function microphone(x,y,z)
    h=1;
    hs = h/4;
    %hold on
    plot3([x,x], [y,y], [z+h/10, z+h], 'black');
    hold on
    plot3([x,x+hs], [y,y], [z+h/10, z], 'black');
    plot3([x,x-hs*0.5], [y,y-hs*sin(pi/3)], [z+h/10, z], 'black');
    plot3([x,x-hs*0.5], [y,y+hs*sin(pi/3)], [z+h/10, z], 'black');
    %figure(2)
    [sx,sy,sz] = sphere(30);
    s= 0.02;
    colormap([0,0,0])
    mesh(s*sx +x,s*sy+ y,s*sz +z+h);
end

function stickfig(x,y,z)
    hl = 0.8;
    dl = 0.4;
    ht = 0.6;
    plot3([x, x], [y+dl/2,y], [z,z+hl], 'black');
    plot3([x, x], [y-dl/2,y], [z,z+hl], 'black');
    plot3([x,x], [y,y], [z+hl,z+hl+ht], 'black');
    plot3([x, x], [y+dl/2,y], [z+hl,z+hl+ht], 'black');
    plot3([x, x], [y-dl/2,y], [z+hl,z+hl+ht], 'black');
    [sx,sy,sz] = sphere(100);
    s= 0.1;
    colormap([0,0,0])
    mesh(s*sx +x,s*sy+ y,s*sz +z+hl+ht+s);
end


function waver(X, Y, Z)
    f = 5;%440/343;
    dx = X(2) - X(1);
    dy = Y(2) - Y(1);
    dz = Z(2) - Z(1);
    d = sqrt(dx^2+ dy^2 +dz^2);
    n=1000;
    x= linspace(X(1), X(2), n);
    y= linspace(Y(1), Y(2), n);
    z= linspace(Z(1), Z(2), n);
    w= linspace(0, 2*pi*f*d, n);
    phi = atan(dx/dy);
    plot3(x-sign(-dx)*0.1*cos(phi)*sin(w),y+0.1*sin(phi)*sin(w),z+0.0*sin(w), 'red');
end