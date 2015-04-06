CRYPT_PATH=''
TEMP_PATH=''
LOG_PATH=''
ARJ_EXE=''
SCSIGN_EXE='C:\\Program Files\\MGTU Bank of Russia\\SignatureSC\\SCSignEx.exe'
BIK=''#full bik number

def get_files_list(path, masks=['*.*']):
    import glob
    import os
    res=set()
    for mask in masks:
        files=[os.path.split(f)[1] for f in glob.glob(os.path.join(path, mask)) if os.path.isfile(f)]
        res.update(files)
    return res

def get_folders_list(path):
    import glob
    import os
    return [f for f in os.listdir(path) if os.path.isdir(os.path.join(path, f))]

def get_crypt_folders(path):
    import os
    folders=get_folders_list(path)
    if folders:
        res_folders=set()
        for f in folders:
            if os.path.exists(os.path.join(path, f, 'settings', 'conf.txt')):
                res_folders.add(f)
        return res_folders
    return None

def get_crypt_settings(conf_file):
    import json
    try:
        with open(conf_file, 'r') as fp:
             data = json.load(fp)
             decr=data['decrypt'] if 'decrypt' in data.keys() else None
             crypt=data['crypt'] if 'crypt' in data.keys() else None
             return crypt, decr
    except Exception as err:
        log('{0}'.format(err), error=True)
        return None, None

def find_keys_path():
    import os
    for d in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'k']:
        keys_path=os.path.join('{0}:\\'.format(d),'keys')
        if os.path.exists(os.path.join(keys_path, 'keys.txt')):
            return keys_path
    return None

def files_count(filemask, setdir=TEMP_PATH):
    import os
    workdir=os.path.join(setdir, replace('COUNT\\%y%\\%m%\\%d%\\'))
    if not os.path.exists(workdir):
        os.makedirs(workdir)
    if os.path.exists(workdir) and '%nnn' in filemask:
        cnt=len(get_files_list(workdir,filemask.replace('%nnnn%','*').replace('%nnn%','*')))
        cnt+=1
        with open(os.path.join(workdir, filemask.replace('%nnnn%','{:0>4}'.format(cnt)).replace('%nnn%','{:0>3}'.format(cnt))),'w') as f:
            f.write('')
        return cnt
    return None

def replace(s):
    import datetime
    d=datetime.datetime.now()
    rs=s.replace('%y%','{0}'.format(d.year))
    rs=rs.replace('%m%','{:0>2}'.format(d.month))
    rs=rs.replace('%d%','{:0>2}'.format(d.day))
    rs=rs.replace('%h%','{:0>2}'.format(d.hour))
    rs=rs.replace('%min%','{:0>2}'.format(d.minute))
    rs=rs.replace('%s%','{:0>2}'.format(d.second))

    rs=rs.replace('%yy%','{0}'.format(d.year)[2:])
    rs=rs.replace('%mm%','{:0>2}'.format(d.month))
    rs=rs.replace('%dd%','{:0>2}'.format(d.day))
    rs=rs.replace('%bik3%',BIK[6:])
    rs=rs.replace('%bik5%',BIK[4:])
    rs=rs.replace('%bik7%',BIK[2:])

    #nnnn nnn ------------------- обязательно допилить номер архива за день!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if '%nnn' in rs:
        cnt=files_count(rs)
        if cnt:
            rs=rs.replace('%nnnn%', '{:0>4}'.format(cnt))
            rs=rs.replace('%nnn%',  '{:0>3}'.format(cnt))
    return rs

def log(text, error=False):
    print(text)
    if error:
        logfile=replace('%y%-%m%-%d%_error.log')
    else:
        logfile=replace('%y%-%m%-%d%.log')
    f=open(logfile, 'a+')
    f.write(text)
    f.write('\n')
    f.close()

def smartmove(src, filename, dst):
    import shutil
    import os

    if not os.path.exists(dst):
        try:
            os.makedirs(dst)
        except FileNotFoundError as err:
            log('Creating output folder error.', error=True)
            log('{0}'.format(err), error=True)
            return False

    try:
        if shutil.copy(os.path.join(src, filename), dst):
            if os.path.exists(os.path.join(dst, filename)):
                os.remove(os.path.join(src, filename))
                log('ok: {0} -> {1}'.format(os.path.join(src,filename), dst))
                return True
    except Exception as err:
        log(err)
        return False
        
def mass_move(src_path, filelist, dst_path):
    import os
    if filelist:
        for f in filelist:
            fullname=os.path.join(src_path, f)
            if os.path.exists(fullname):
                smartmove(src_path, f, dst_path)

def chext(path, filelist, new_ext):
    import os
    res=True
    if filelist:
        for f in filelist:
            new_name= '{0}.{1}'.format(os.path.splitext(f)[0], new_ext)
            try:
                os.rename(os.path.join(path,f), os.path.join(path, new_name))
            except Exception as err:
                log('{0}'.format(err), error=True)
                return False
            if os.path.exists(os.path.join(path, new_name)):
                log('ok rename: {0} -> {1}'.format(os.path.join(path, f), new_name))
            else:
                log('error rename: {0} -> {1}'.format(os.path.join(path, f), new_name), error=True)
                res=False
    return res

def is_cab(path, filename):
    import os
    fb=open(os.path.join(path, filename),'rb')
    bts=fb.read(4)
    fb.close()
    if bts==b'MSCF':
        return True
    else:
        return False

def is_arj(path, filename):
    import os
    fb=open(os.path.join(path, filename),'rb')
    bts=fb.read(2)
    fb.close()
    if bts==b'`\xea':
        return True
    else:
        return False

def is_crypted(path, filename):
    import os
    fb=open(os.path.join(path, filename),'rb')
    bts=fb.read(100)
    fb.close()
    if bts[:3]==b'a94':
        serial = bts[1:7].decode()
        key = bts[95:99].decode()
        return key
    else:
        return False

def is_signed(path, filename):
    import os
    fb=open(os.path.join(path, filename),'rb')
    bts=fb.read()
    fb.close()
    if bts[-98:-91]==b'o000000' and bts[-1:]==b'\x00':
        serial = bts[-23:-17].decode()
        key = bts[-27:-23].decode()
        return key
    else:
        return False

def is_clear_file(path, filename):
    import os
    fb=open(os.path.join(path, filename),'rb')
    bts=fb.read()
    fb.close()
    if not (bts[-98:-91]==b'o000000' and bts[-1:]==b'\x00') and bts[:3]!=b'a94' and bts[:2]!=b'`\xea' and bts[:4]!=b'MSCF':
        return True
    else:
        return False

def get_key_dir(key, keys_path):
    import json
    import os
    try:
        with open(os.path.join(keys_path, 'keys.txt'), 'r') as fp:
             data = json.load(fp)
             keys_list=data['keys'] if 'keys' in data.keys() else None
             if keys_list:
                 for key_fldr, key_par in keys_list.items():
                     if key in key_par.values():
                         return os.path.join(keys_path, key_fldr)
             return None
    except Exception as err:
        log('{0}'.format(err), error=True)
        return None

def get_key_dir_keyname(keyname, keys_path):
    import json
    import os
    try:
        with open(os.path.join(keys_path, 'keys.txt'), 'r') as fp:
             data = json.load(fp)
             names_list=data['names'] if 'names' in data.keys() else None
             if names_list:
                 abonent=names_list[keyname] if keyname in names_list.keys() else None
                 if abonent:
                     keys_list=data['keys'] if 'keys' in data.keys() else None
                     if keys_list:
                         for key_fldr, key_par in keys_list.items():
                             if abonent in key_par.keys():
                                 return os.path.join(keys_path, key_fldr), key_par[abonent]
             return None, None
    except Exception as err:
        log('{0}'.format(err), error=True)
        return None, None

def un_cab(path, filename):
    import os
    t_dir=os.path.join(path,filename.replace('.{0}'.format(BIK[6:]),''))
    if not os.path.exists(t_dir):
        os.makedirs(t_dir)
    if os.path.exists(t_dir):
        log('expand -r "{0}" "{1}"'.format(os.path.join(path, filename),t_dir))
        os.system('expand -r "{0}" "{1}"'.format(os.path.join(path, filename),t_dir))
        files=get_files_list(t_dir)
        if files:
            mass_move(t_dir, get_files_list(t_dir), path)
            os.removedirs(t_dir)
            os.remove(os.path.join(path, filename))
            return True
    return False

def un_arj(path, filename):
    import os
    t_dir=os.path.join(path,filename.replace('.ARJ','').replace('.arj',''))
    if not os.path.exists(t_dir):
        os.makedirs(t_dir)
    if os.path.exists(t_dir):
        log('""{0}" e "{1}" "{2}" -u -y"'.format(ARJ_EXE, os.path.join(path, filename), t_dir))
        os.system('""{0}" e "{1}" "{2}" -u -y"'.format(ARJ_EXE, os.path.join(path, filename), t_dir))
        files=get_files_list(t_dir)
        if files:
            mass_move(t_dir, get_files_list(t_dir), path)
            os.removedirs(t_dir)
            os.remove(os.path.join(path, filename))
            return True
    return False

def pack_arj(path, files, arj_filename):
    import os
    log('"cd /d {3} && "{0}" m -ey "{1}" "{2}" "'.format(ARJ_EXE, arj_filename, '" "'.join(files), path))
    os.system('"cd /d {3} && "{0}" m -ey "{1}" "{2}" "'.format(ARJ_EXE, arj_filename, '" "'.join(files), path))
    if os.path.exists(arj_filename):
        return True
    else:
        return False

def un_crypt(path, filename, key_dir, sc_logfile):
    import os
    if key_dir and os.path.exists(key_dir):
        os.system('subst a: "{0}"'.format(key_dir))
        os.system('""{0}" -d -f{1} -b0 -o{2}"'.format(SCSIGN_EXE, os.path.join(path, filename), sc_logfile))
        log('""{0}" -d -f{1} -b0 -o{2}"'.format(SCSIGN_EXE, os.path.join(path, filename), sc_logfile))
        os.system('subst a: /d')
        return True
    else:
        self.log('Can''t find key directory to uncrypt file {0}'.format(key_dir), error=True)
        return False

def un_sign(path, filename, key_dir, sc_logfile):
    import os
    if key_dir and os.path.exists(key_dir):
        os.system('subst a: "{0}"'.format(key_dir))
        os.system('""{0}" -r -f{1} -b0 -o{2}"'.format(SCSIGN_EXE, os.path.join(path, filename), sc_logfile))
        log('""{0}" -r -f{1} -b0 -o{2}"'.format(SCSIGN_EXE, os.path.join(path, filename), sc_logfile))
        os.system('subst a: /d')
        return True
    else:
        self.log('Can''t find key directory to uncrypt file {0}'.format(key_dir), error=True)
        return False

##-----------------------------------------
def sign(path, filename, key_dir, sc_logfile):
    import os
    if key_dir and os.path.exists(key_dir):
        os.system('subst a: "{0}"'.format(key_dir))
        log('subst a: "{0}"'.format(key_dir))
        os.system('""{0}" -s -f{1} -b0 -o{2}"'.format(SCSIGN_EXE, os.path.join(path, filename), sc_logfile))
        log('""{0}" -s -f{1} -b0 -o{2}"'.format(SCSIGN_EXE, os.path.join(path, filename), sc_logfile))
        os.system('subst a: /d')
        return True
    else:
        self.log('Can''t find key directory to sign file {0}'.format(key_dir), error=True)
        return False

def encrypt(path, filename, abonent, key_dir, sc_logfile):
    import os
    if key_dir and os.path.exists(key_dir):
        os.system('subst a: "{0}"'.format(key_dir))
        log('subst a: "{0}"'.format(key_dir))
        os.system('""{0}" -e -a{1} -f{2} -b0 -o{3}"'.format(SCSIGN_EXE, abonent, os.path.join(path, filename), sc_logfile))
        log('""{0}" -e -a{1} -f{2} -b0 -o{3}"'.format(SCSIGN_EXE, abonent, os.path.join(path, filename), sc_logfile))
        os.system('subst a: /d')
        return True
    else:
        self.log('Can''t find key directory to crypt file {0}'.format(key_dir), error=True)
        return False


##-----------------------------------------

def decrypt(name, in_path, decr_params, keys_path, temp_path, log_path):
    import os
    sc_logfile=replace('{0}\\%y%%m%%d%_{1}.log'.format(log_path, name.replace('-','_')))
    temp_path=os.path.join(temp_path, name)
    print(decr_params)
    print(keys_path)

    if not os.path.exists(temp_path):
        os.makedirs(temp_path)
    if not os.path.exists(log_path):
        os.makedirs(log_path)

    masks=decr_params['masks'] if 'masks' in decr_params.keys() else ['*.*']

    #перемещение
    in_files=get_files_list(in_path, masks)
    if in_files:
        mass_move(in_path, in_files, temp_path)

    #распаковка cab
    cab_files=[f for f in get_files_list(temp_path) if is_cab(temp_path, f)]
    for f in cab_files:
        un_cab(temp_path, f)

    #распаковка arj
    arj_files=[f for f in get_files_list(temp_path) if is_arj(temp_path, f)]
    for f in arj_files:
        un_arj(temp_path, f)

    #расшифровка и снятие ЭЦП
    all_files=get_files_list(temp_path)
    for f in all_files:
        key=is_crypted(temp_path, f)
        if key:
            un_crypt(temp_path, f, get_key_dir(key, keys_path), sc_logfile)
        elif key!=False:
            log('Can''t find key {0} to uncrypt file'.format(key), error=True)

        key=is_signed(temp_path, f)
        if key:
            un_sign(temp_path, f, get_key_dir(key, keys_path), sc_logfile)
        elif key!=False:
            log('Can''t find key {0} to unsign file'.format(key), error=True)

    #переименование
    rename=decr_params['rename'] if 'rename' in decr_params.keys() else None
    if rename:
        for mask, new_ext in rename.items():
            files=get_files_list(temp_path, [mask])
            if files:
                while not chext(temp_path, files, new_ext):
                    pass

    #перемещение обработанных файлов в выходную папку
    outdir=decr_params['outdir'] if 'outdir' in decr_params.keys() else ''
    if not outdir:
        outdir=in_path
    all_total = [f for f in get_files_list(temp_path) if is_clear_file(temp_path, f)]
    if all_total:
        mass_move(temp_path, all_total, outdir)
        return all_total
    return None

def crypt(name, out_path, cr_params, keys_path, temp_path, log_path):
    import os
    sc_logfile=replace('{0}\\%y%%m%%d%_{1}.log'.format(log_path, name.replace('-','_')))
    temp_path=os.path.join(temp_path, name)
    print(cr_params)
    print(keys_path)

    if not os.path.exists(temp_path):
        os.makedirs(temp_path)
    if not os.path.exists(log_path):
        os.makedirs(log_path)

    outdir=cr_params['outdir'] if 'outdir' in cr_params.keys() else ''

    #переименование
    rename=cr_params['rename'] if 'rename' in cr_params.keys() else None
    if rename:
        for mask, new_ext in rename.items():
            files=get_files_list(out_path, [mask])
            if files:
                while not chext(out_path, files, new_ext):
                    pass

    #цифовая подпись ЭЦП
    sign_masks=[]
    sign_par=cr_params['sign'] if 'sign' in cr_params.keys() else None
    if sign_par:
        sign_masks=sign_par['masks'] if 'masks' in sign_par.keys() else []
        key=sign_par['abonent'] if 'abonent' in sign_par.keys() else None
        for_sign=[f for f in get_files_list(out_path, sign_masks) if not is_signed(out_path, f) and not is_crypted(out_path, f)]
        if for_sign and key:
            for f in for_sign:
                sign(out_path, f, get_key_dir_keyname(key, keys_path)[0], sc_logfile)

    #шифрование
    crypt_masks=[]
    crypt_par=cr_params['encrypt'] if 'encrypt' in cr_params.keys() else None
    if crypt_par:
        crypt_masks=crypt_par['masks'] if 'masks' in crypt_par.keys() else []
        key=crypt_par['abonent'] if 'abonent' in crypt_par.keys() else None
        for_crypt=[f for f in get_files_list(out_path, crypt_masks) if not is_crypted(out_path, f)]
        if for_crypt and key:
            #шифруем только если список файлов подлежащих простановке ЭЦП пуст
            if not [f for f in get_files_list(out_path, sign_masks) if not is_signed(out_path, f) and not is_crypted(out_path, f)]:
                for f in for_crypt:
                    key_dir, abonent=get_key_dir_keyname(key, keys_path)
                    encrypt(out_path, f, abonent, key_dir, sc_logfile)

    #упаковка
    arj_par=cr_params['arj'] if 'arj' in cr_params.keys() else None

    arj_masks=[]   
    #упаковываем только если все необходимые файлы подписаны ЭЦП и зашифрованы
    if (not [f for f in get_files_list(out_path, sign_masks) if not is_signed(out_path, f) and not is_crypted(out_path, f)] and
        not [f for f in get_files_list(out_path, crypt_masks) if not is_crypted(out_path, f)]):
        if arj_par:
            for arj in arj_par:
                arj_masks=arj['masks'] if 'masks' in arj.keys() else None
                arj_arj_mask=arj['arj_mask'] if 'arj_mask' in arj.keys() else None
                if arj_masks and arj_arj_mask:
                    arj_files=get_files_list(out_path, arj_masks)
                    archive_filename=replace(arj_arj_mask)
                    if arj_files and pack_arj(out_path, arj_files, os.path.join(out_path, archive_filename)):
                        #Выясняем нужно ли проставить эцп на архив
                        arj_sign_key=arj['sign_key'] if 'sign_key' in arj.keys() else None
                        if arj_sign_key:
                            sign(out_path, archive_filename, get_key_dir_keyname(arj_sign_key, keys_path)[0], sc_logfile)
                            if is_signed(out_path, archive_filename):
                                log('ok sign {0}'.format(archive_filename))
                                if outdir:
                                    smartmove(out_path, archive_filename, outdir)
                        else:
                            if outdir:
                                smartmove(out_path, archive_filename, outdir)
    if outdir:
        #получаем все маски файлов для архивирования в виде множества
        masks_for_arj=[e['masks'] for e in arj_par] if arj_par else []
        arj_masks_set=set()
        for e in masks_for_arj:
            arj_masks_set.update(set(e))
	
        signed_files={f for f in get_files_list(out_path, sign_masks) if is_signed(out_path, f) or is_crypted(out_path, f)} if sign_masks else set()
        crypted_files={f for f in get_files_list(out_path, crypt_masks) if is_crypted(out_path, f)} if crypt_masks else set()
        to_be_arjed={f for f in get_files_list(out_path, arj_masks_set)} if arj_masks_set else set()
        files_for_move=signed_files.union(crypted_files).difference(to_be_arjed)
        if files_for_move:
            mass_move(out_path, files_for_move, outdir)
   
def process(root, folder):
    import os
    crypt_params, decrypt_params = get_crypt_settings(os.path.join(root, folder, 'settings', 'conf.txt'))
    keys_path=find_keys_path()
    if decrypt_params and keys_path:
        decrypt(folder, os.path.join(root, folder, 'in'), decrypt_params, keys_path, TEMP_PATH, LOG_PATH)
    if crypt_params and keys_path:
        crypt(folder, os.path.join(root, folder, 'out'), crypt_params, keys_path, TEMP_PATH, LOG_PATH)
        
#---------------main loop---------------------
while True:
    folders=get_crypt_folders(CRYPT_PATH)
    if folders:
        print(folders)
        for f in folders:
            process(CRYPT_PATH, f)
    
    break
