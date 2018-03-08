function [ t, obj_order ] = AT( Points, minimization, normalization )
% AT Aggregation Tree for the points in X
% 
% Points has a row for each point and a column for each objective
% Minimization is 1 for minimization and 0 for maximization
% 
% Reference:
% Aggregation Trees for Visualization and Dimension Reduction in Many-Objective Optimization
% ARR de Freitas, PJ Fleming, FG Guimarães - Information Sciences, 2014 - Elsevier
%
% Example:
% load example_data;
% % Usual parallel coordinate plot
% tradeoff(obj);
% % Aggregation Tree with Polar Graph
% AT(obj);
%
% $Author: Alan de Freitas $    $Date: 2015/03/20 $    $Revision: 1.31 $
%
%
%
% This work is licensed under a Creative Commons 
% Attribution-NonCommercial 3.0 Unported License.
% http://creativecommons.org/licenses/by-nc/3.0/deed.en_US
%
% Copyright: 2012
% 
% 

%% Initializes tree with all objectives as children
% Initialize variables
X = Points;
n_points = size(X,1);
n_obj = size(X,2);

%disp('X');
%disp(X);
% Creates a tree with the root and functions as nodes
t = tree;
pos = zeros(1,n_obj); % position of original objectives
for i=1:n_obj
    [t,pos(i)] = t.addnode(1, i);%cada objetivo da árvore é um nó.
end

% Maximum locality of conflict
l_max = 0;
fX_line = linspace(-1,1,n_points);
for i=1:floor(n_points/2) % an "i" for each positive number in fX_line
    left = i;
    right = n_points - i + 1;
    l_max = l_max + abs(right-left)*fX_line(right);
end
%disp('pos');
%disp(pos);

%% Normalize objective values
% Values for maximization are inverted
if ~exist('minimization','var')||isempty(minimization)
    minimization = ones(1,n_obj);
end
for i=1:n_obj
    % if a certain objective is maximization
    if minimization(i) == 0
        % its values are inverted
        X(:,i) = -X(:,i);
    end
end
% Values of X are normalized
if ~exist('normalization','var')||isempty(normalization)
    normalization = 1;
end

if (normalization == 1)||(strcmp(normalization,'rank')) % according to rank
    %----------- Cria matriz com valores repetidos -----------------------------
    % A matriz R tem tamanho igual a da matriz X, porém a matriz R ordena cada coluna atribuindo valor igual para os elementos com o mesmo valor
    % Por exemplo se temos como entrada os seguinte pontos (matriz), ou
    % Points:
    % 232 321
    % 254 311
    % 232 311
    % 254 303
    % Teriamos uma matriz R ordenada indicando os valores repetidos da
    % seguinte forma:
    % 1 3
    % 2 2
    % 1 2
    % 2 1
    % Isso indica que na primeira coluna os elementos na posição 1 e 3 são
    % os menores e são repetidos, da mesma forma os elementos 2 e 4 são o
    % segundo elemento menor e são repetidos. Par a segunda coluna, podemos
    % observar que o elemento 4 é o menor, o elemento 2 e 3 é o segundo
    % menor e tem valores iguais, e por fim, o elemento 1 é o maior. A
    % matriz R ajuda a verificar os elemento respetidos e ordenar isso da
    % melhor forma, pois se fossemos reordenar a matriz X, olhamos a matriz
    % R e podemos reordenar os valores que são repetidos para
    % que o conflito seja mínimo. Por exemplo, se quisermos reordenar a
    % coluna 1 podemos reordenar os valores que tem valor 1 em R e depois o
    % que tem valor 2 em R.
    for i=1:n_obj
        [~,~,R(:,i)] = unique(X(:,i));
    end
    %---------------------------------------------------------------------------
    [~,rank] = sort(X);
    for i=1:n_obj
        X(rank(:,i),i) = 1:n_points;
    end
    c_max = 2*(ceil(n_points/2)*(n_points+1) - (2*(1+ceil(n_points/2))*(ceil(n_points/2)))/2);
elseif (normalization == 2)||(strcmp(normalization,'minmax')) % according to min max
    minimum = min(X);
    for i=1:n_obj
        X(i,:) = X(i,:) - minimum;
    end
    maximum = max(X);
    for i=1:n_obj
        X(i,:) = X(i,:)./maximum;
    end
    c_max = n_points;
elseif (normalization == 3)||(strcmp(normalization,'direct')) % according to minimum
    minimum = min(X);
    for i=1:n_obj
        X(i,:) = X(i,:) - minimum;
    end
end

%disp('cmax');
%disp(c_max);
%disp('R');
%disp(R);
%disp('X - objetivos normalizados');
%disp(X);

pos_line = pos; % position of current objectives in the tree
%disp('pos line = pos');
%disp(pos_line);

objetivos = 1:n_obj; %variável para controlar qual será a agregação, resolvi colocar este vetor pois como disse a um tempo atrás o código estava com erro e não estava agregando os objetivos que tinham menor valor
% o vetor "objetivos" controla isso para que a agregação seja correta. Este
% vetor é inicializado com os número entre 1 e o número de objetivos do
% problema se o problema possui 4 objetivo, por exemplo, o vetor objetivos
% é inicializado com 1 2 3 4.
% While we are considering more than one objective

agregacao = 0;% agregação é feita se no caso de a escolha de agregação ter sido feita utilizando o critério de desempate ele verifica que atraves deste vetor, que o objetivo a ser agregado é o que objetivo da iteração anterior. 
for iter=1:n_obj-1
    %% Remakes X_line as a sum current objectives in the tree
    %disp('Nova Iteração ---------------------------------------------------------------------------------------');
    %disp('posline');
    %disp(pos_line);
    X_line = zeros(n_points, length(pos_line)); % X(n_points, num of current objectives)
    % For each current objective
	Narvore = 1; %aqui agente inicializa "Narvore" igual a 1, pois o primeiro nó da árvore é o nó raíz
    for i=1:length(pos_line)
        % if the objective is an original objective, that is, a leaf node
        %disp('verificando coluna');
        %disp(i);
        %disp('verificando nó');
        %disp(Narvore+1);
        if isleaf(t,Narvore+1)%aqui verificamos se "Narvore+1" é folha caso seja:
            % just copy the value to X_line(:,i) from the original X
            %disp('copiou');
            X_line(:,i) = X(:,t.get(pos_line(i)));%a copia da coluna é feita
			Narvore = Narvore + 1;% e Narvore é incrementado em 1 para verficiar o próximo nó a ser verificado
        else % caso o Narvore+1 não seja folha entramos aqui
            % in the general case, we have to find the strings (leaves) in the node
            leaves = findleaves(t.subtree(Narvore+1))+Narvore;%aqui encontramos as folhas da subárvore Narvores+1, repare que se temos uma sub árvores com duas folhas, ele retornará 1 e 2
            %por isso somamos t.subtree(Narvore+1) com Narvores para assim
            %na árvore como um todo, e não como uma subárvore, ele aponta
            %para os elementos exatos na árvore que contém todos os nós.
            Narvore = Narvore + t.subtree(Narvore+1).nnodes; % depois disso atualizamos o Narvores para controlar onde a verificação parou, repare que somamos Narvore + o número de nós
            % da subarvore;
            % we detect the objective related to each string
            obj = zeros(1,length(leaves));
            for j=length(leaves):-1:1
                obj(j) = t.get(leaves(j));
            end
            %disp('obj');
            %disp(obj);
            % the values of those objectives are summed and attributed to
            % the objective
            %disp('Objetivos somados');
            %disp(obj);
            X_line(:,i) = sum(X(:,obj),2);
            %disp('X_line(:,i)');
            %disp(X_line(:,i));
        end
    end
    %disp('objetivos');
    %disp(objetivos);
    %disp('X');
    %disp(X);
    %disp('X line Iniciado');
    %disp(X_line);
    %disp('R');
    %disp(R);
    %disp('X line Após a soma');
    %disp(X_line);
    
    %% The values are normalized again for X_line
    if (normalization == 1) % according to rank
        [~,rank] = sort(X_line);
        for i=1:length(pos_line)
            X_line(rank(:,i),i) = 1:n_points;
        end
    elseif (normalization == 2) % according to min max
        minimum = min(X_line);
        for i=1:n_points
            X_line(i,:) = X_line(i,:) - minimum;
        end
        maximum = max(X_line);
        for i=1:n_points
            X_line(i,:) = X_line(i,:)./maximum;
        end
    elseif (normalization == 3) % according to minimum
        minimum = min(X_line);
        for i=1:n_points
            X_line(i,:) = X_line(i,:) - minimum;
        end
    end
    %disp('X line normalizado novamente, depois da soma');
    %disp(X_line);
    %disp('Rank refeito apos a soma');
    %disp(rank);
    
    %% Harmony between all the objectives
    if normalization == 1
        X_rank = X_line;
    else
        X_rank = zeros(n_points, length(pos_line));
        [~,rank] = sort(X_line);
        for i=1:length(pos_line)
            X_rank(rank(:,i),i) = 1:n_points;
        end
    end
    
    % Calculates harmony table between the current objectives
    X_melhor = X_line;
    H_melhor = c_max+1;
    H = nan(length(pos_line),length(pos_line));
    %disp('Looping Calcula Harmonia ----------------------------------------------------------------------------');
    for i=1:length(pos_line)
        for j=i+1:length(pos_line)
            %fprintf('Avaliando harmonia entre %d e %d \n', i, j);
            Rcopy = R;%Rcopy recebe matriz R;
            entreI = 0;
            entreJ = 0;
            for k=1:n_points % para cada elemento da coluna
                %fprintf('verificando elemento = %d\n',k);
                repJ = find( Rcopy(:,j) == Rcopy(k,j) ); % verifica se o elemento k tem valores repetidos na coluna j
                repI = find( Rcopy(:,i) == Rcopy(k,i) ); % verifica se o elemento k tem valores repetidos na coluna i
                %fprintf('%d elemento repetidos para o objetivo %d\n',length(repI),i);
                %fprintf('%d elemento repetidos para o objetivo %d\n',length(repJ),j);
                if length(repI) > 1 && length(repI) > 1 % caso os dois tenham valores repetidos vamos ordenar o que tem mais valores repetidos;
                    if length(repJ) > length(repI)
                        entreJ = 1;
                    else
                        entreI = 1;
                    end
                end
                % verificamos qual coluna para a posição k tem mais valores repetidos pois temos
                % que ordenanar o que tem o maior número de valores
                % repedidos. Por exemplo se I e J tem valores repetidos,
                % porém I tem mais valores repetidos, fixamos J e
                % reordenamos os valores repetidos de I para igualar a
                % coluna J o máximo possível, gerando assim o menor
                % conflito entre I e J.
                if length(repI) > 1 && entreJ == 0 %verificamos se a coluna I tem valores repetidos e iguais ao elemento comparado k, caso tenha: 
                    %fprintf('Ajeitando objetivo %d\n',i);
                    entreI = 1; % "entreI" igual a 1 pois queremos ordenar somente a coluna I, e queremos fixar J
                    valoresJ = X_line(repI,j); %valoresJ recebe os elementos da coluna j das posições de RepI. Por exemplo se temos a seguinte coluna: 2 4 3 6 1 5 e os valores dos
                    %indices 1, 3 e 5 são repetidos, valoresJ = 2, 3, 1.
                    valoresI = X_line(repI,i); %valoresI recebe os elementos da coluna i das posições de RepI. Por exemplo se temos a seguinte coluna: 4 2 5 1 6 3 e os valores dos
                    %indices 1, 3 e 5 são repetidos, valoresI = 4, 5, 6.
                    [~,indiceJ] = sort(valoresJ);%ordena valoresJ e salva os indices destes valores ordenados em indiceJ. Por exemplo, se valoresJ = 2 3 1, ordenamos estes valores que
                    %fica 1 2 3, assim pegamos os indices dos valores
                    %ordenados, assim, o elemento 1 tem indice 3, o
                    %elemento 2 tem indice 1 e o elemento 3 tem indice 2,
                    %logo, indiceJ = 3 1 2.
                    alvo = repI(indiceJ);%alvo recebe os indices ordenados porem considerando toda a coluna. Por exemplo, os valores repetidos são 1 3 5 que são estão computados em repI.
                    % indiceJ = 3 1 2, logo o primeiro elemento de indiceJ
                    % é igual a 3, a posição 3 em repI é igual a 5, o
                    % segundo elemento de indiceJ é igual a 1, a posição 1
                    % em repI é igual a 1, e por fim, o terceiro elemento
                    % de indiceJ é igual a 2, a posição 2 em repI é igual a
                    % 3, logo alvo = 5 1 3.
                    order = sort(valoresI); %ordena valores de I. 
                    X_rank(alvo,i) = order;%aqui acontece os elementos de I são colocados de forma que o menor elemento de valoresI seja casado com o menor elemento de valoresJ,
                    %o segundo menor elemento de valoresI seja casado com o
                    %segundo menor elemento de valoresJ e assim por diante.
                    Rcopy(alvo,i) = order; %o mesmo acontece para Rcopy, os elemento são cadados da mesma forma que para X_rank.
                    clear repOrdenados;
                    %Resumo do Processo Acima
                    % Exemplo: se temos a seguinte matriz Points, resultando nas seguintes matrizes X_rank e Rcopy:
                    % Points:       X_rank      Rcopy
                    %  i   j        i    j      i   j
                    % 200 195       4    2      3   2
                    % 195 210       2    4      2   4
                    % 200 200       5    3      3   3
                    % 123 220       1    6      1   6
                    % 200 190       6    1      3   1
                    % 195 213       3    5      2   5
                    %
                    %Repare que X_line ordena os elementos e os que são
                    %repetidos são ordenados de forma que os das primeiras
                    %linha são considerado melhores. Ja na matriz R não,
                    %ele ordena e demonstra a ordem dos elemento e se existirem valores iguais é considerado empate, e o valores em Rcopy ficam iguais para valores repetidos.
                    %Então o processo acima verifica em R na primeira linha
                    %das colunas i e j se tem valores repetidos, repare que
                    %a coluna j não tem valores repetidos para nenhuma
                    %elemento. No entanto, a coluna i tem valores repetidos
                    %para o primeiro elemento (3), podemos ver ainda que
                    %existem 3 elementos iguais ao elemento da coluna i e
                    %na primeira linha. O que o algoritmo faz, verifica a
                    %posição dos elemento repetidos, são as posições 1, 3 e
                    %5, e verifica os elementos desta posições em X_line
                    %para as colunas i e j. Bom, se ja sabemos as posições
                    %que são repetidos pegamos os valores destas posições.
                    %Este são:
                    % i   j
                    % 4   2
                    % 5   3
                    % 6   1
                    %Como os valores repetidos estão na coluna i procuramos
                    %casar o menor valor de i com o menor valor de j, o
                    %segundo menor valor de i com o segundo menor valor de
                    %j, e assim por diante, considerando os elementos das
                    %posições repetidas. Desta forma obtemos a menor
                    %diferença possível.
                    % Neste caso Casariamos os elemento repetidos da seguinte forma:
                    % i   j
                    % 5   2
                    % 6   3
                    % 4   1
                    %Assim os elementos repetidos agora estão ordenados de forma que o menor conflito seja considerado entre os objetivos comparados, e a matriz X_rank e Rcopy ficam da seguinte forma:
                    % X_rank    Rcopy
                    % i   j     i   j
                    % 5   2     5   2
                    % 2   4     2   4
                    % 6   3     6   3
                    % 1   6     1   6
                    % 4   1     4   1
                    % 3   5     2   5
                    % Repare que agora a matriz Rcopy ainda possui
                    % elementos iguais para ordenar e o processo é repetido
                    % novamento para os elemento com valor 2, neste caso
                    % estes elementos tem que ser escolhidos de tal forma
                    % que um receba o valor 2 e o outro o valor 3 para que
                    % o menor conflito seja alcançado. O mesmo processo é
                    % feito quando elementos repetidos são encontrados na
                    % coluna J. Lembrando que se as duas colunas possuem
                    % elementos repetidos aquela coluna que apresentar o
                    % maior número de elementos repetidos para o elemento k
                    % será ajustada, fixando a outra coluna.
                elseif length(repJ) > 1 && entreI == 0;
                    %fprintf('Ajeitando objetivo %d\n',j);
                    entreJ = 1;
                    valoresJ = X_line(repJ,j);
                    valoresI = X_line(repJ,i);
                    [~,indiceI] = sort(valoresI);
                    alvo = repJ(indiceI);
                    order = sort(valoresJ);
                    X_rank(alvo,j) = order;
                    Rcopy(alvo,j) = order;
                    clear repOrdenados;
                end
            end
            H(i,j) = sum(abs(X_rank(:,i)-X_rank(:,j)));%Dado que os elementos repetidos foram ajustados, pode-se calcular a harmonia entre estes.
            if H(i,j) <= H_melhor%aqui a configuração que apresentou a maior harmonia é salva
               H_melhor = H(i,j);%H_melhor computa o valor de melhor harmonia
               X_melhor = X_rank;%X_melhor computado a configuração de X_rank que apresentou a menor harmonia.
            end
            X_rank = X_line;%X_rank recebe X_line novamente para que o processo inicie novamente para os outros objetivos a serem comparados. Isso porque uma coluna que possue elemento
            %repetidos deve se ajustada a cada outra coluna individualmente, um ajuste de uma coluna que possui elementos repetidos possui outra ordem para outra coluna para que o
            %conflito seja mínimo possível. Aquela configuração de X_rank
            %que apresentar menor harmonia é a escolhida, ou seja, se temos
            %uma coluna que apresenta valores repetidos, este é ajustado
            %com aquela coluna (objetivo) que apresenta menor conflito.
        end
    end

    for i=1:length(pos_line)
        for j=1:i-1
            H(i,j) = H(j,i);
        end
    end
    %disp('H');
    %disp(H);
    %disp('minH');
    %disp(min(H));
    %% Finds where is maximum harmony
    
    [h_max,a] = min(H);
    [~,b] = min(h_max);
    a = a(b); %objectives i and j have conflict the least = a
    %fprintf('objetivo a = %d tem menor conflito com objetivo b = %d\n',a,b);
    
    %verifica se a escolha do objetivo foi arbitrária----------------------
    primeiroA = H(1,a);%primeiroA recebe o primeiro elemento da matriz da coluna a, primeiro elemento de um dos objetivos que apresentou menor conflito
    primeiroB = H(1,b);%primeiroB recebe o primeiro elemento da matriz da coluna b, primeiro elemento do outro objetivo que apresentou menor conflito
    if a == 1%se a for igual a 1 primeiroA recebe o segundo elemento, isso porque se a for igual a 1, ou seja a primeira coluna, o primeiro elemento é NAN
        primeiroA = H(2,a);
    end
    if b == 1%se b for igual a 1 primeiroB recebe o segundo elemento, isso porque se b for igual a 1, ou seja a primeira coluna, o primeiro elemento é NAN
        primeiroB = H(2,b);
    end
    aleatorioA = 0;
    aleatorioB = 0;
    for i=1:length(H(a,:))%este for verifica se os elementos da coluna 'a' não possuem o mesmo valor
        if i ~= a && primeiroA ~= H(a,i)%não compara elementos da mesma posição
            aleatorioA = 1;%caso coluna 'a' não possua valores iguais em todas as linhas, aleatoriaA recebe 1
        end
    end
    for i=1:length(H(b,:))%este for verifica se os elementos da coluna 'b' não possuem o mesmo valor
        if i ~= b && primeiroB ~= H(b,i)%não compara elementos da mesma posição
            aleatorioB = 1;%caso coluna 'b' não possua valores iguais em todas as linha, aleatoriaB recebe 1
        end
    end
    
    if iter == agregacao %agregação é declarada na linha 140, se iter == agregacao, significa que a iteracao anterior dexou algum objetivo na reserva pois ele tinha harmonia igual 
        % aos outros objetivos, e esta harmonia era a maior. Deste modo,
        % esta iteração deve agregar o objetivo que ficou na reserva com o
        % objetivos agregados na iteracao anterior (segundo maior harmonia).
        %disp('Sequencia da iteração anteior agregando obj arbitrário');
        a = length(H(:,1));%assim, 'a' recebe a ultima coluna, isso pq o objetivo agregado da iteração anterior é sempre somado e colocado na ultima coluna da matriz. 
        [~,b] = min(H(:,a));%'b' recebe a coluna que apresenta a melhor harmonia, assim, sabe-se que à ultima coluna se deve agregador a coluna que apresenta menor harmonia. 
    elseif aleatorioA == 0 && iter < n_obj-2%se aleatoriaA for igual a zero significa que o objetivo a tem valores iguais para todas as linha e foi escolhida aleatoriamente
       agregacao = iter+1; %agregação recebe iter+1, deste modo agregacao sera igual a iter na iteração seguinte e entreta no primeiro if.
       %disp('Coluna a escolhido aleatoriamente');
       [h_max,maiorA] = max(H);%encontra o pior valor na matriz de harmonia
       [~,maiorB] = max(h_max);%encontra o pior valor na matriz de harmonia
       maiorA = maiorA(maiorB);%encontra o pior valor na matriz de harmonia
       H(a,:) = H(maiorA,maiorB)+1;%o objetivo que foi escolhido aleatoriamente recebe o pior valor de harmonia para sua coluna
       H(:,a) = H(maiorA,maiorB)+1;%o objetivo que foi escolhido aleatoriamente recebe o pior valor de harmonia para sua linhas
       H(a,a) = nan;
       [h_max,a] = min(H);%Calcula a segunda melhor harmonia entre os objetivos
       [~,b] = min(h_max);%Calcula a segunda melhor harmonia entre os objetivos
       a = a(b); %objectives i and j have conflict the least = a
       % o elseif seguinte faz o mesmo processo no caso em que o objetivo b
       % foi escolhido aleatoriamente.
    elseif aleatorioB == 0 && iter < n_obj-2%se aleatoriaA for igual a zero significa que o objetivo a tem valores iguais para todas as linha e foi escolhida aleatoriamente
       agregacao = iter+1;
       %disp('Coluna b escolhido aleatoriamente');
       [h_max,maiorA] = max(H);
       [~,maiorB] = max(h_max);
       maiorA = maiorA(maiorB);
       H(b,:) = H(maiorA,maiorB)+1;
       H(:,b) = H(maiorA,maiorB)+1;
       H(b,b) = nan;
       [h_max,a] = min(H);
       [~,b] = min(h_max);
       a = a(b); %objectives i and j have conflict the least = a
    end
    %-------------------------------------------------------------
    
    %disp('maior harmonia');
    %disp(a);
    %disp(b);
    
    %disp('X_melhor');
    %disp(X_melhor);
    
    %% Calculates conflict between those objectives
    % Conflict as difference of normalized value
    X_line = X_melhor;
    %disp('objetivos');
    %disp(objetivos);
    %disp('X_line');
    %disp(X_line);
    %disp('confliito é a soma entre a e b');
    %disp(X_line(:,a));
    %disp(X_line(:,b));
    if objetivos(a) ~= 0%se o vetor objetivos na posição do objetivo 'a' for diferente de zero entra no if
        X(:,objetivos(a)) = X_line(:,a);%copia a coluna 'a' de X_line para a coluna objetivos(a) de X;
        R(:,objetivos(a)) = X_line(:,a);%copia a coluna 'a' de X_line para a coluna objetivos(a) de R;
    end%as cópias acima são feitas pois é possível que se altere X quando ajustamos colunas de objetivos que tem valores repetidos, quando chegamos neste ponto do código
    %já sabemos qual é o melhor ajuste para um objetivo que tem valores
    %repetidos, e atualizamos X e R com a coluna ajustada para a melhor
    %haromina possível.
     
    if objetivos(b) ~= 0%o mesmo é feito para o objetivo 'b'
        X(:,objetivos(b)) = X_line(:,b);
        R(:,objetivos(b)) = X_line(:,b);
    end
    objetivos(a) = [];%retira coluna do objetivo 'a'
    objetivos(b) = [];%retira coluna do objetivo 'b'
    objetivos(end+1) = 0;%insere coluna no final do vetor objetivos que representa a coluna agreagação 'a'+'b';
    %resumo do processo acima:
    %se temos seis objetivo por exemplo, o vetor objetivos = 1 2 3 4 5 6, se
    %agregamos os objetivo 2 e 5 atualizamos o vetor objetivos = 1 3 4 6 0,
    %assim, sabemos que os objetivos 1, 3, 4 e 6 ainda não foram agregados.
    %O vetor objetivos serve mesmo para que a cópia de X_line feita para X
    %e R seja feita da forma certa.
    
    c = sum(abs(X_line(:,a)-X_line(:,b)));%calcula conflito entre a e b
    %disp('Somatório de conflito entre a e b sem normalizar');
    %disp(c);
    % Normalizing this difference from 0 to 1
    if (normalization < 3) % we can only do this for rank and maxmin
        c = c / c_max;
    end
    %disp('conflito normalizado');
    %disp(c);
    
    %% Locality of conflict
    la = 0;
    for i=1:n_points
        la = la + abs(X_line(i,a)-X_line(i,b))*fX_line(X_rank(i,a));
    end
    la = la/l_max;
    
    lb = 0;
    for i=1:n_points
        lb = lb + abs(X_line(i,b)-X_line(i,a))*fX_line(X_rank(i,b));
    end
    lb = lb/l_max;
    
    %% Moves the subtrees of a and b into a new root node
    children = getchildren(t,1); % children of root node
    t1 = t.subtree(children(a)); % children of compound obj a
    t2 = t.subtree(children(b)); % children of compound obj b
    [t, newnode]=t.addnode(1,[c,la,lb]); % add node to root with the conflict and locality of a & b
    t = t.graft(newnode, t1); % put a's subtree under the new node
    t = t.graft(newnode, t2); % put b's subtree under the new node
    t = t.chop(children(a)); % chop a's subtree
    t = t.chop(children(b)); % chop b's subtree
    
    % Updates the number of current objectives with n-1 objectives
    % Objective a and b were removed and replaced by newnode in the root
    % node
    pos_line = 2:n_obj+1-iter;
    R(:,a) = [];%a coluna 'a' é retira da matriz R pois foi agregada
    R(:,b) = [];%a coluna 'b' é retira da matriz R pois foi agregada
    R(:,length(pos_line)) = 1:n_points;
    %disp('arvore');
    %disp(t);
    %disp('X_line final - passado para a próxima iteração');
    %disp(X_line);
    %disp('nos');
    %for i=1:t.nnodes
    %   disp(t.get(i)); 
    %end
    
end

%% Plot the final harmony tree

% The empty root node desapears
t = t.subtree(2);

% A new tree t2 will keep the size of the conexion between nodes.
% It's going to be proportional to the conflict
% Make the new tree with conflict = 0 for the leaves
t2 = t;
for i=1:t.nnodes
    if (t.isleaf(i))
        t2 = t2.set(i,0);
    else
        a = t2.get(i);
        t2 = t2.set(i,1);%a(1));
    end
end

% Makes a new tree with strings for the leaves "f_x" and nodes
t3 = t;
for i=1:t.nnodes
    if (t.isleaf(i))
        t3 = t3.set(i,['$f_{',num2str(t.get(i)),'}$']);
    else
        % gets what is in the node
        a = get(t,i);
        % gets the conflict from it
        a = a(1);
        % gets the subtree
        st = t.subtree(i);
        % finds which objectives that compose it
        temp_objectives = st.findleaves;
        % creates a string with the compound objectives
        str = '$';
        for j=1:length(temp_objectives)
            if j<length(temp_objectives)
                str = [str,'f_{',num2str(get(st,temp_objectives(j))),'}+'];
            else
                str = [str,'f_{',num2str(get(st,temp_objectives(j))), '}'];
            end
        end
        % puts a string in the same place for t3
        if normalization < 3
            t3 = t3.set(i,[str,'-',num2str(a*100),'\%$']);
        else
            t3 = t3.set(i,[str,'-',num2str(a)]);
        end
    end
end

% plots the tree with the strings and conflict represented on the size of
% branches
figure(1);
%set(0, 'defaultTextInterpreter', 'latex'); 
[vlh, hlh, tlh] = t3.plot(t2);%0;, 'YLabel', {'Summed' 'Conflict'});
h_max = ylim;
h_max(1) = h_max(1) - 0.3;
h_max(2) = h_max(2) + 0.3;
ylim(h_max);

%% Colors the tree accordingly to the locality of conflict
rcolor = [1 0 0];
bcolor = [0 0 1];
kcolor = [0 0 0];

for i = 1:t.nnodes
    % The text becomes black if it is the root node
    if i == 1
        set( tlh.get(i), 'Color' , kcolor )
    else
        % else, the text color represents the region of conflict in the
        % parent
        % gets the information of conflict from the parent
        p = t.getparent(i);
        l = t.get(p);
        % the color of the bar represents the siblings
        l2 = (l(2)<0).*rcolor.*abs(l(2)) + (l(2)>0).*bcolor.*abs(l(2));
        l3 = (l(2)<0).*rcolor.*abs(l(3)) + (l(3)>0).*bcolor.*abs(l(3));
        set( hlh.get(p), 'Color' , (l2 + l3)./2);
        %set( hlh.get(p), 'Color' , kcolor);
        % finds which one represents the specific region
        sibling = t.getsiblings(i);
        if find(i==sibling)==1
            l = l(2);
        else
            l = l(3);
        end
        % color of the text is red for negative values and blue for positive
        % (l<=0).*rcolor.*l + (l>=0).*bcolor.*l
        set( tlh.get(i), 'Color' , (l<=0).*rcolor.*abs(l) + (l>=0).*bcolor.*abs(l) );
%        set( tlh.get(i), 'Color' , kcolor )
        % the lines are all black
        set( vlh.get(i), 'Color' , kcolor );
%        set( vlh.get(i), 'Color' , (l<=0).*rcolor.*abs(l) + (l>=0).*bcolor.*abs(l) )
    end
end

objetos = findall(gcf);
for i=1:length(objetos);
   temp = get(objetos(i));
   if (strcmp(temp.Type,'text')==1)
       set(objetos(i),'Interpreter','latex');
   end
end

%% Plot polar graph

obj_order = zeros(1,n_obj);
leaves = findleaves(t);
for i=1:n_obj
    obj_order(i) = t.get(leaves(i));
end

% disp(['Ordem ', num2str(obj_order)]);

% Plots a polar graph with the order of the leaves
polargraph(Points,obj_order);

end

