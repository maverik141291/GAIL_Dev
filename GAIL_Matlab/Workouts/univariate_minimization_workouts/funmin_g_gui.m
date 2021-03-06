function [fmin,npoints,errest] = funmin_g_gui(f,a,b,tol,nlo,nhi,varargin)
%funmin_g_gui Demonstrate numerical approximation of an univaraite function.
%   fmin = funmin_g_gui(f,a,b) shows the steps in approximating the function
%   f(x) from a to b by locally adaptive guaranteed method.
%   The color switches to green when the desired accuracy is obtained.
%
%   fmin = funmin_g_gui(f,a,b,tol) uses the given tolerance instead of 1.e-3
%   and returns an approximated function fmin%
%
%   [fmin, npoints] = funmin_g_gui(f,...) also gives the number points
%   needed of approximation.
%
%   Examples:
%  [fmin,npoints,errest] = funmin_g_gui(@(x) x.^2,-1,1,1e-2,10,20)
%  [fmin,npoints,errest] = funmin_g_gui(@(x) exp(-1000*(x-0.2).^2),0,1,1e-3,10,20)
%  [fmin,npoints,errest] = funmin_g_gui(@(x) exp(-1000*(x-0.2).^2),0,1,1e-6,10,20)
%   Flat function:
%  [fmin,npoints,errest] = funmin_g_gui(@(x) exp(-1./(x - 0.5).^2),0,1,1e-4,2,2)
%  [fmin,npoints,errest] = funmin_g_gui(@(x) sin(2*pi*x),0,1,1e-3,10,20)
%  Two local min:
%  [fmin,npoints] = funmin_g_gui(@(x) -5 * exp(-(10*(x - .3)).^2) - exp(-(10*(x - 0.75)).^2),0,1,1e-3,10,20)
%  [fmin,npoints] = ... 
%  Demo with funminNoPenalty_g:
%  [fmin,npoints,errest] = funmin_g_gui(@(x) x.^2,-1,1,1e-2,10,20,'funminNoPenalty_g')
shg
clf reset
MATLABVERSION= gail.matlab_version;
if isempty(varargin)
  algoname = 'funmin_g';
  algo = @(f,in_param) funmin_g(f,in_param);
else 
  algoname= varargin{1};
  algo = str2func(['@(f,in_param)', varargin{1},'(f,in_param)']);  
end
warning('off', ['GAIL:',algoname, ':exceediter']);


% Default tolerance
if nargin < 5
    nlo = 10;
    nhi = 1000;
end

if nargin < 4
    tol = 1.e-7;
    nlo = 10;
    nhi = 1000;
end

% Default function and interval.
if nargin < 3
    f = @(x) x.^2;
    a = 0;
    b = 1;
    tol = 1.e-3;
    nlo = 10;
    nhi = 1000;
end

% Initialization
fa = f(a);
fb = f(b);
k = 0;

% Scale the plot
h = b - a;

ninit = 2*ceil(nhi*(nlo/nhi)^(1/(1+h)))+1;
x = a:h/(ninit-1):b;
y = f(x);
maxy = max(y);
miny = min(y);
set(gcf,'doublebuffer','on','userdata',0)
plot(x,y,'.','markersize',15);
hold on
p(1) = fill(a,fa,'k');
p(2) = fill(b,fb,'k');
hold off
s = (maxy - miny)/5;
axis([a b miny-s maxy+s])
% q(1) = uicontrol('string','step', ...
%     'units','normal','pos',[.65 .02 .08 .04], ...
%     'callback','set(gcf,''userdata'',1)');
% q(2) = uicontrol('string','auto', ...
%     'units','normal','pos',[.75 .02 .08 .04], ...
%     'callback','set(gcf,''userdata'',2)');
% q(3) = uicontrol('string','quit', ...
%     'units','normal','pos',[.85 .02 .08 .04], ...
%     'callback','set(gcf,''userdata'',3)');
q(1) = uicontrol('string','step', ...
    'units','normal','pos',[.75 .02 .08 .04], ...
    'callback','set(gcf,''userdata'',1)');
q(2) = uicontrol('string','auto', ...
     'units','normal','pos',[.85 .02 .08 .04], ...
    'callback','set(gcf,''userdata'',2)');
%index = [1 ninit];
% initialize nstar
%nstar = ninit - 2;
%nstar = floor(ninit/2);
% initialize error
err = tol+1;

in_param.a = a; 
in_param.b = b; 
in_param.abstol = tol; 
in_param.nlo = nlo; 
in_param.nhi = nhi; 
in_param.output_x = true;
tmpstr = strsplit(algoname,'_g');
while(max(err) > tol)
    if max(err) > tol;
        in_param.maxiter = k+1; 
        [~,out_param] = algo(f,in_param);
        err = out_param.errest;
        npoints = out_param.npoints;
        x = out_param.x;
        y = f(x);
        k = k + 1;
        p = flipud(get(gca,'children'));
        set(p(1),'xdata',x,'ydata',y)
        set(gca,'xtick',x,'xticklabel',[]);
        hTitle=title([tmpstr{1}, '\_g: error is ' num2str(max(err)) ' in iter ' num2str(k)]);
        set(hTitle,'FontSize',25)
        pause(.25)
        while get(gcf,'userdata') == 0
            pause(.25)
        end
        if get(gcf,'userdata') == 1
            set(gcf,'userdata',0)
        end
    else
        k = k + 1;
        break;
    end;
end

p = flipud(get(gca,'child'));
set(p(1),'xdata',x,'ydata',y)
set(gca,'xtick',x,'xticklabel',[]);
hTitle=title([tmpstr{1}, '\_g: error estimation is ' num2str(max(err)) ' in iteration ' num2str(k)]);
set(hTitle,'FontSize',25)
pause(.25)
while get(gcf,'userdata') == 0
    pause(.25)
end
if get(gcf,'userdata') == 1
    set(gcf,'userdata',0)
end
%npoints = index(end);
if MATLABVERSION >= 8.3
    fmin = griddedInterpolant(x,y,'linear');
else
    pp = interp1(x,y,'linear','pp');
    fmin =@(x) ppval(pp,x);
end;
errest = max(err);
%delete(p)
delete(q);
warning('on', ['GAIL:', algoname ,':exceediter']);

hold on;
delta = 0.00001;
x=a:delta:b; 
plot(x,f(x));
hold off;
gail.save_eps('WorkoutfunminOutput', [algoname, '_gui']);

% ---------------------------------------------------------
