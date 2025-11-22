#!/usr/bin/env bash
# Install and enable VM guest integrations

log_info "Checking VM environment..."

DETECTED_VM=$(systemd-detect-virt 2>/dev/null || echo "none")

detect_vm_type() {
    case "$DETECTED_VM" in
        vmware)
            echo "vmware"
            ;;
        qemu|kvm)
            echo "qemu"
            ;;
        oracle)
            echo "virtualbox"
            ;;
        *)
            echo "none"
            ;;
    esac
}

AUTO_DETECTED=$(detect_vm_type)

if [[ "$AUTO_DETECTED" != "none" ]]; then
    log_info "Auto-detected VM type: $AUTO_DETECTED"
    if ask_yesno "Use auto-detected VM type ($AUTO_DETECTED)?" "yes"; then
        VM_TYPE="$AUTO_DETECTED"
    fi
fi

if [[ -z "${VM_TYPE:-}" ]]; then
    selected=$(ask_menu "Select VM environment:" \
        "VMware" \
        "QEMU/UTM" \
        "VirtualBox" \
        "Bare metal (none)")
    
    if [[ -z "$selected" ]]; then
        log_error "No VM type selected"
        return 1
    fi
    
    case "$selected" in
        "VMware") VM_TYPE="vmware" ;;
        "QEMU/UTM") VM_TYPE="qemu" ;;
        "VirtualBox") VM_TYPE="virtualbox" ;;
        "Bare metal (none)") VM_TYPE="baremetal" ;;
        *)
            log_error "Unknown VM type: $selected"
            return 1
            ;;
    esac
fi

if [[ "$VM_TYPE" == "baremetal" ]]; then
    log_info "Bare metal detected - no VM guest tools needed"
    log_success "VM support configuration complete (bare metal)"
    return 0
fi

log_info "Configuring VM guest tools for: $VM_TYPE"

case "$VM_TYPE" in
    vmware)
        log_info "Installing VMware guest tools..."
        ensure_pacman_pkg open-vm-tools
        
        log_info "Enabling VMware services..."
        ensure_service "vmtoolsd.service"
        ensure_service "vmware-vmblock-fuse.service"
        
        log_success "VMware guest tools configured"
        ;;
    
    qemu)
        log_info "Installing QEMU guest agent..."
        ensure_pacman_pkg qemu-guest-agent
        
        log_info "Enabling QEMU guest agent service..."
        ensure_service "qemu-guest-agent.service"
        
        log_success "QEMU guest agent configured"
        ;;
    
    virtualbox)
        log_info "Installing VirtualBox guest utilities..."
        ensure_pacman_pkg virtualbox-guest-utils
        
        log_info "Enabling VirtualBox guest service..."
        ensure_service "vboxservice.service"
        
        log_success "VirtualBox guest utilities configured"
        ;;
    
    *)
        log_error "Unknown VM type: $VM_TYPE"
        return 1
        ;;
esac

log_success "VM support configuration complete"

